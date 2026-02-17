<?php

define('ACCESS_ALLOWED', true);

$config = require __DIR__ . '/config.php';

$APP_ENV      = $config['APP_ENV'];
$API_SECRET   = $config['API_SECRET'];
$BACKEND_BASE = $config['BACKEND_BASE'];
$RATE_LIMIT   = $config['RATE_LIMIT'];
$LOG_FILE = __DIR__ . '/access.log';

$RATE_WINDOW = 900;
$CLEANUP_INTERVAL = 3600;

// Whitelist Endpoints
$ALLOWED_ENDPOINTS = [
    '/api/auth/login',
    '/api/auth/register',
    '/api/auth/change-password',
    '/api/users',
    '/api/users/me',
    '/api/bookings',
    '/api/routes',
    '/api/vehicles',
    '/api/maps',
    '/api/notifications',
    '/api/driver-verifications',
];


function logAccess($status, $message = '', $code = '') {
    global $LOG_FILE;
    $timestamp = date('Y-m-d H:i:s');
    $ip = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
    $method = $_SERVER['REQUEST_METHOD'] ?? 'UNKNOWN';
    $endpoint = $_GET['endpoint'] ?? $_SERVER['PATH_INFO'] ?? 'unknown';
    
    $log_entry = sprintf(
        "[%s] %s | Code: %s | IP: %s | Method: %s | Endpoint: %s | %s\n",
        $timestamp, str_pad($status, 10), str_pad($code, 3), 
        str_pad($ip, 15), str_pad($method, 6), $endpoint, $message
    );
    
    @file_put_contents($LOG_FILE, $log_entry, FILE_APPEND | LOCK_EX);
}

function sendError($code, $message, $details = null) {
    http_response_code($code);
    header('Content-Type: application/json');
    $response = [
        'success' => false,
        'error' => $message,
        'timestamp' => date('Y-m-d H:i:s')
    ];
    if ($details) {
        $response['debug_details'] = $details;
    }
    echo json_encode($response);
    exit;
}


function buildMultipartBody() {
    global $APP_ENV;
    
    // ตรวจสอบว่ามีไฟล์หรือไม่
    if (empty($_FILES) && empty($_POST)) {
        return null;
    }
    
    // สร้าง Boundary ใหม่
    $boundary = '----PHPGatewayBoundary' . md5(uniqid());
    $body = '';
    
    // เพิ่ม POST fields
    foreach ($_POST as $key => $value) {
        $body .= "--$boundary\r\n";
        $body .= "Content-Disposition: form-data; name=\"$key\"\r\n\r\n";
        $body .= "$value\r\n";
    }
    
    // เพิ่ม Files
    foreach ($_FILES as $fieldName => $file) {
        // รองรับทั้ง single file และ multiple files
        if (is_array($file['name'])) {
            // Multiple files
            foreach ($file['name'] as $index => $filename) {
                if (empty($filename)) continue;
                
                $filePath = $file['tmp_name'][$index];
                $fileContent = file_get_contents($filePath);
                $mimeType = $file['type'][$index];
                
                $body .= "--$boundary\r\n";
                $body .= "Content-Disposition: form-data; name=\"{$fieldName}[]\"; filename=\"$filename\"\r\n";
                $body .= "Content-Type: $mimeType\r\n\r\n";
                $body .= $fileContent . "\r\n";
            }
        } else {
            // Single file
            if (!empty($file['name'])) {
                $filename = $file['name'];
                $filePath = $file['tmp_name'];
                $fileContent = file_get_contents($filePath);
                $mimeType = $file['type'];
                
                $body .= "--$boundary\r\n";
                $body .= "Content-Disposition: form-data; name=\"$fieldName\"; filename=\"$filename\"\r\n";
                $body .= "Content-Type: $mimeType\r\n\r\n";
                $body .= $fileContent . "\r\n";
            }
        }
    }
    
    // ปิด Boundary
    $body .= "--$boundary--\r\n";
    
    if ($APP_ENV === 'development') {
        error_log("📦 Built multipart body: " . strlen($body) . " bytes");
        error_log("📋 Boundary: $boundary");
    }
    
    return [
        'body' => $body,
        'boundary' => $boundary
    ];
}

/**
 * Filter headers
 */
function getForwardHeaders($skipContentType = false) {
    $headers = [];
    $blocked = [
        'host',
        'content-length',
        'connection',
        'accept-encoding',
        'transfer-encoding',
        'expect',
        'proxy-connection'
    ];
    
    // ถ้าเป็น multipart ให้บล็อก Content-Type เดิมด้วย (จะใส่ใหม่)
    if ($skipContentType) {
        $blocked[] = 'content-type';
    }

    if (function_exists('getallheaders')) {
        $all = getallheaders();
    } else {
        $all = [];
        foreach ($_SERVER as $name => $value) {
            if (substr($name, 0, 5) == 'HTTP_') {
                $headerName = str_replace(' ', '-', ucwords(strtolower(str_replace('_', ' ', substr($name, 5)))));
                $all[$headerName] = $value;
            }
        }
    }

    foreach ($all as $name => $value) {
        $lower = strtolower($name);
        
        if (in_array($lower, $blocked)) {
            continue;
        }
        
        if (empty($value) || 
            stripos($value, 'undefined') !== false || 
            stripos($value, 'null') !== false) {
            continue;
        }
        
        $headers[] = "$name: $value";
    }
    
    $headers[] = "X-Forwarded-Gateway: PHP-Proxy";
    $headers[] = "X-Real-IP: " . ($_SERVER['REMOTE_ADDR'] ?? 'unknown');
    $headers[] = "Expect:";
    
    return $headers;
}

/**
 * Proxy Request
 */
function proxyRequest($target_url, $method, $body, $headers) {
    global $APP_ENV;
    
    $ch = curl_init();
    
    $user_agent = $_SERVER['HTTP_USER_AGENT'] ?? 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36';

    curl_setopt_array($ch, [
        CURLOPT_URL => $target_url,
        CURLOPT_CUSTOMREQUEST => $method,
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_FOLLOWLOCATION => true,
        CURLOPT_HEADER => true,
        CURLOPT_TIMEOUT => 120,
        CURLOPT_CONNECTTIMEOUT => 30,
        CURLOPT_USERAGENT => $user_agent,
        CURLOPT_SSL_VERIFYPEER => false,
        CURLOPT_SSL_VERIFYHOST => 0,
        CURLOPT_IPRESOLVE => CURL_IPRESOLVE_V4,
        CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
    ]);
    
    if (!empty($body) && in_array($method, ['POST', 'PUT', 'PATCH'])) {
        curl_setopt($ch, CURLOPT_POSTFIELDS, $body);
        
        if ($APP_ENV === 'development') {
            error_log("📤 Sending body: " . strlen($body) . " bytes");
        }
    }
    
    curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
    
    if ($APP_ENV === 'development') {
        curl_setopt($ch, CURLOPT_VERBOSE, true);
        $verbose = fopen('php://temp', 'w+');
        curl_setopt($ch, CURLOPT_STDERR, $verbose);
    }
    
    $response = curl_exec($ch);
    $error_msg = curl_error($ch);
    $error_no = curl_errno($ch);
    
    if ($APP_ENV === 'development' && isset($verbose)) {
        rewind($verbose);
        $verboseLog = stream_get_contents($verbose);
        error_log("🔍 cURL Verbose:\n" . $verboseLog);
        fclose($verbose);
    }
    
    if ($response === false) {
        curl_close($ch);
        return [
            'success' => false,
            'error' => "cURL Error ($error_no): $error_msg",
            'code' => 502
        ];
    }
    
    $header_size = curl_getinfo($ch, CURLINFO_HEADER_SIZE);
    $status_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    
    curl_close($ch);
    
    return [
        'success' => true,
        'headers' => substr($response, 0, $header_size),
        'body' => substr($response, $header_size),
        'code' => $status_code
    ];
}

// Main Logic
try {
    // CORS Preflight
    if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
        http_response_code(204);
        header("Access-Control-Allow-Origin: *");
        header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS, PATCH");
        header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
        header("Access-Control-Max-Age: 86400");
        exit;
    }

    //รับ Endpoint
    $endpoint = $_GET['endpoint'] ?? $_SERVER['PATH_INFO'] ?? '';
    
    if (empty($endpoint)) {
        sendError(400, 'Endpoint required');
    }

    $endpoint = preg_replace('/[^a-zA-Z0-9\/_.-]/', '', $endpoint);
    if (strpos($endpoint, '/api') !== 0) {
        $endpoint = '/api/' . ltrim($endpoint, '/');
    }

    // Whitelist Check
    $is_allowed = false;
    foreach ($ALLOWED_ENDPOINTS as $allowed) {
        if (strpos($endpoint, $allowed) === 0) {
            $is_allowed = true;
            break;
        }
    }
    
    if (!$is_allowed) {
        sendError(404, 'Endpoint not allowed', $endpoint);
    }

    //เตรียม URL
    $target_url = rtrim($BACKEND_BASE, '/') . $endpoint;
    
    $query_string = $_SERVER['QUERY_STRING'] ?? '';
    parse_str($query_string, $params);
    unset($params['endpoint'], $params['key']);
    if (!empty($params)) {
        $target_url .= '?' . http_build_query($params);
    }

    //เตรียม Data
    $method = $_SERVER['REQUEST_METHOD'];
    $content_type = $_SERVER['CONTENT_TYPE'] ?? '';
    
    //ตรวจสอบว่าเป็น Multipart หรือไม่
    $is_multipart = (stripos($content_type, 'multipart/form-data') !== false);
    
    if ($is_multipart) {
        //สร้าง Multipart Body ใหม่
        $multipart = buildMultipartBody();
        
        if ($multipart === null) {
            sendError(400, 'Invalid multipart data');
        }
        
        $body = $multipart['body'];
        $headers = getForwardHeaders(true); // บล็อก Content-Type เดิม
        
        //ใส่ Content-Type ใหม่พร้อม Boundary ที่ถูกต้อง
        $headers[] = "Content-Type: multipart/form-data; boundary=" . $multipart['boundary'];
        
        if ($APP_ENV === 'development') {
            error_log("=== 📦 MULTIPART REQUEST ===");
            error_log("Files count: " . count($_FILES));
            error_log("POST count: " . count($_POST));
            error_log("Body size: " . strlen($body) . " bytes");
        }
    } else {
        //ข้อมูลปกติ (JSON, URL-encoded)
        $body = file_get_contents('php://input');
        $headers = getForwardHeaders(false);
        
        if ($APP_ENV === 'development') {
            error_log("=== 📄 STANDARD REQUEST ===");
            error_log("Content-Type: $content_type");
            error_log("Body size: " . strlen($body) . " bytes");
        }
    }

    // Debug Headers
    if ($APP_ENV === 'development') {
        error_log("Target: $target_url");
        error_log("Method: $method");
        error_log("Headers:");
        foreach ($headers as $h) {
            error_log("  - $h");
        }
    }

    // Proxy Request
    $result = proxyRequest($target_url, $method, $body, $headers);

    // Handle Response
    if (!$result['success']) {
        logAccess('ERROR', $result['error'], 502);
        sendError(502, 'Gateway Connection Failed', $result['error']);
    }

    http_response_code($result['code']);

    $response_headers = explode("\r\n", $result['headers']);
    foreach ($response_headers as $header) {
        if (empty($header)) continue;
        
        $lower_header = strtolower($header);
        if (stripos($lower_header, 'transfer-encoding') === false && 
            stripos($lower_header, 'connection') === false &&
            stripos($lower_header, 'http/') === false) {
            header($header, false);
        }
    }

    header("Access-Control-Allow-Origin: *");
    header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS, PATCH");
    header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");

    echo $result['body'];
    
    logAccess('SUCCESS', "Proxied to $target_url", $result['code']);

} catch (Exception $e) {
    logAccess('CRITICAL', $e->getMessage(), 500);
    sendError(500, 'Internal Server Error', $e->getMessage());
}
?>