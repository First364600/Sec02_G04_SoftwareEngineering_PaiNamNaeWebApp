*** Variables ***
${X-GATEWAY-KEY}    knsifKslfDFHlfeiasdfASDFejiasdfASDFejaAsdfkj

${BASE_URL}            http://localhost:3000

${LOGIN_URL}        ${BASE_URL}/api/auth/login
${REGISTER_URL}        ${BASE_URL}/api//users
${BOOKING_ROUTE_URL}      ${BASE_URL}/api/bookings

# คนขับ
${DRIVER_VERIFICATION_URL}    ${BASE_URL}/api/driver-verifications
${ROUTE_URL}    ${BASE_URL}/api/routes
${CREATE_VEHICLE_URL}    ${BASE_URL}/api/vehicles

# แอดมิน
${ADMIN_EMAIL}              admin@example.com
${ADMIN_USERNAME}           admin123
${ADMIN_PASSWORD}           123456789
${ADMIN_FIRST_NAME}         System
${ADMIN_LAST_NAME}          Administrator

${ADMIN_VERIFIED_DRIVER_URL}    ${BASE_URL}/api/users/admin