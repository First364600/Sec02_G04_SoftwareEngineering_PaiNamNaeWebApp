-- AlterTable
ALTER TABLE "Booking" ADD COLUMN     "driverCancelRequest" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "passengerStatus" "PassengerTripStatus",
ADD COLUMN     "reachedDropoff" BOOLEAN NOT NULL DEFAULT false;
