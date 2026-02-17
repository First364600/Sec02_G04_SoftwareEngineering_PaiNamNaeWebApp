/*
  Warnings:

  - Added the required column `updatedAt` to the `DeleteAccountRequest` table without a default value. This is not possible if the table is not empty.
  - Made the column `state` on table `DeleteAccountRequest` required. This step will fail if there are existing NULL values in that column.

*/
-- AlterTable
-- Rename existing primary key constraint if present (separate statement)
ALTER TABLE "DeleteAccountRequest" RENAME CONSTRAINT "id" TO "DeleteAccountRequest_pkey";

-- Add new columns (each in separate ALTER TABLE statements to avoid parser issues)
ALTER TABLE "DeleteAccountRequest" ADD COLUMN "approvedBy" TEXT;
ALTER TABLE "DeleteAccountRequest" ADD COLUMN "approvedDate" TIMESTAMP(3);
ALTER TABLE "DeleteAccountRequest" ADD COLUMN "completedDate" TIMESTAMP(3);
ALTER TABLE "DeleteAccountRequest" ADD COLUMN "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE "DeleteAccountRequest" ADD COLUMN "ipAddress" TEXT;
ALTER TABLE "DeleteAccountRequest" ADD COLUMN "notes" TEXT;
ALTER TABLE "DeleteAccountRequest" ADD COLUMN "reason" TEXT;
ALTER TABLE "DeleteAccountRequest" ADD COLUMN "scheduledDeletionDate" TIMESTAMP(3);
ALTER TABLE "DeleteAccountRequest" ADD COLUMN "updatedAt" TIMESTAMP(3) NOT NULL;
ALTER TABLE "DeleteAccountRequest" ADD COLUMN "userAgent" TEXT;

-- Alter existing columns
ALTER TABLE "DeleteAccountRequest" ALTER COLUMN "date" SET DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE "DeleteAccountRequest" ALTER COLUMN "state" SET NOT NULL;
ALTER TABLE "DeleteAccountRequest" ALTER COLUMN "state" SET DEFAULT 'PENDING';

-- CreateIndex
CREATE INDEX "DeleteAccountRequest_userId_idx" ON "DeleteAccountRequest"("userId");

-- CreateIndex
CREATE INDEX "DeleteAccountRequest_state_idx" ON "DeleteAccountRequest"("state");

-- CreateIndex
CREATE INDEX "DeleteAccountRequest_date_idx" ON "DeleteAccountRequest"("date");

-- CreateIndex
CREATE INDEX "DeleteAccountRequest_scheduledDeletionDate_idx" ON "DeleteAccountRequest"("scheduledDeletionDate");
