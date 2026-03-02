-- DropForeignKey
ALTER TABLE "DeleteAccountRequest" DROP CONSTRAINT "DeleteAccountRequest_userId_fkey";

-- AlterTable
ALTER TABLE "DeleteAccountRequest" ALTER COLUMN "userId" DROP NOT NULL;

-- AddForeignKey
ALTER TABLE "DeleteAccountRequest" ADD CONSTRAINT "DeleteAccountRequest_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;
