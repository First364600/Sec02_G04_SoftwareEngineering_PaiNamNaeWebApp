/*
  Warnings:

  - You are about to drop the column `approvedDate` on the `DeleteAccountRequest` table. All the data in the column will be lost.
  - You are about to drop the column `completedDate` on the `DeleteAccountRequest` table. All the data in the column will be lost.
  - You are about to drop the column `date` on the `DeleteAccountRequest` table. All the data in the column will be lost.

*/
-- DropIndex
DROP INDEX "DeleteAccountRequest_date_idx";

-- AlterTable
ALTER TABLE "DeleteAccountRequest" DROP COLUMN "approvedDate",
DROP COLUMN "completedDate",
DROP COLUMN "date",
ADD COLUMN     "approvedAt" TIMESTAMP(3),
ADD COLUMN     "completedAt" TIMESTAMP(3),
ADD COLUMN     "requestedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP;

-- CreateIndex
CREATE INDEX "DeleteAccountRequest_requestedAt_idx" ON "DeleteAccountRequest"("requestedAt");

-- RenameForeignKey
ALTER TABLE "DeleteAccountRequest" RENAME CONSTRAINT "userId" TO "DeleteAccountRequest_userId_fkey";
