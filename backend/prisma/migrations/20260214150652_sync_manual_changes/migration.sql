-- CreateTable
CREATE TABLE "DeleteAccountRequest" (
    "userId" TEXT NOT NULL,
    "date" TIMESTAMP(3) NOT NULL,
    "state" TEXT,
    "id" TEXT NOT NULL,

    CONSTRAINT "id" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "DeleteAccountRequest" ADD CONSTRAINT "userId" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE NO ACTION ON UPDATE CASCADE;
