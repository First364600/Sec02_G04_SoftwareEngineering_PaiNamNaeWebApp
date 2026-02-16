-- AlterEnum
ALTER TYPE "RouteStatus" ADD VALUE 'ARRIVED';

-- AlterTable
ALTER TABLE "Route" ADD COLUMN     "currentStep" INTEGER NOT NULL DEFAULT 0;
