const cron = require('node-cron');
const userService = require('./user.service');

// Cron job สำหรับลบบัญชีที่ครบกำหนด 90 วัน
// ทำการตรวจสอบทุกวันเวลา 02:00 น.
const initializeSchedulers = () => {
    // เรียกทุกวันเวลา 02:00 น.
    cron.schedule('0 2 * * *', async () => {
        console.log('🔄 Processing scheduled account deletions...');
        try {
            const deletedCount = await userService.processScheduledDeletions();
            console.log(`✓ Processed ${deletedCount} account deletion(s)`);
        } catch (error) {
            console.error('✗ Error processing scheduled deletions:', error);
        }
    });

    console.log('✓ Schedulers initialized');
};

// สำหรับทดสอบ ให้เรียกฟังก์ชันนี้เพื่อลบทันที
const processDeletedAccountsManually = async () => {
    console.log('🔄 Manually processing scheduled account deletions...');
    try {
        const deletedCount = await userService.processScheduledDeletions();
        console.log(`✓ Processed ${deletedCount} account deletion(s)`);
        return deletedCount;
    } catch (error) {
        console.error('✗ Error processing scheduled deletions:', error);
        throw error;
    }
};

module.exports = {
    initializeSchedulers,
    processDeletedAccountsManually,
};
