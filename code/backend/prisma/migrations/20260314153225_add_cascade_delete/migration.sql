-- DropForeignKey
ALTER TABLE "TripMessage" DROP CONSTRAINT "TripMessage_bookingId_fkey";

-- DropForeignKey
ALTER TABLE "TripMessage" DROP CONSTRAINT "TripMessage_senderId_fkey";

-- DropForeignKey
ALTER TABLE "TripMessageReply" DROP CONSTRAINT "TripMessageReply_senderId_fkey";

-- AddForeignKey
ALTER TABLE "TripMessage" ADD CONSTRAINT "TripMessage_senderId_fkey" FOREIGN KEY ("senderId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TripMessage" ADD CONSTRAINT "TripMessage_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES "Booking"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TripMessageReply" ADD CONSTRAINT "TripMessageReply_senderId_fkey" FOREIGN KEY ("senderId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
