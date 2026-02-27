/*
  Warnings:

  - You are about to drop the column `created_at` on the `SystemLog` table. All the data in the column will be lost.
  - You are about to drop the column `ip_address` on the `SystemLog` table. All the data in the column will be lost.
  - You are about to drop the column `log_hash` on the `SystemLog` table. All the data in the column will be lost.
  - You are about to drop the column `status_code` on the `SystemLog` table. All the data in the column will be lost.
  - You are about to drop the column `user_agent` on the `SystemLog` table. All the data in the column will be lost.
  - You are about to drop the column `user_id` on the `SystemLog` table. All the data in the column will be lost.

*/
-- CreateEnum
CREATE TYPE "LogType" AS ENUM ('AUTH', 'TRANSACTION', 'BEHAVIOR', 'SECURITY');

-- DropForeignKey
ALTER TABLE "SystemLog" DROP CONSTRAINT "SystemLog_user_id_fkey";

-- DropIndex
DROP INDEX "SystemLog_user_id_created_at_idx";

-- AlterTable
ALTER TABLE "SystemLog" DROP COLUMN "created_at",
DROP COLUMN "ip_address",
DROP COLUMN "log_hash",
DROP COLUMN "status_code",
DROP COLUMN "user_agent",
DROP COLUMN "user_id",
ADD COLUMN     "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN     "details" JSONB,
ADD COLUMN     "ipAddress" TEXT,
ADD COLUMN     "logHash" TEXT,
ADD COLUMN     "logType" "LogType" NOT NULL DEFAULT 'TRANSACTION',
ADD COLUMN     "statusCode" INTEGER,
ADD COLUMN     "userAgent" TEXT,
ADD COLUMN     "userId" TEXT,
ALTER COLUMN "action" SET DATA TYPE TEXT,
ALTER COLUMN "method" SET DATA TYPE TEXT,
ALTER COLUMN "endpoint" SET DATA TYPE TEXT;

-- AddForeignKey
ALTER TABLE "SystemLog" ADD CONSTRAINT "SystemLog_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;
