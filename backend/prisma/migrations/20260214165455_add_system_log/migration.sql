-- CreateTable
CREATE TABLE "SystemLog" (
    "id" SERIAL NOT NULL,
    "user_id" TEXT,
    "action" VARCHAR(255) NOT NULL,
    "method" VARCHAR(10) NOT NULL,
    "endpoint" VARCHAR(255) NOT NULL,
    "ip_address" VARCHAR(50) NOT NULL,
    "user_agent" TEXT,
    "status_code" INTEGER,
    "log_hash" VARCHAR(64),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "SystemLog_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "SystemLog_user_id_created_at_idx" ON "SystemLog"("user_id", "created_at");

-- AddForeignKey
ALTER TABLE "SystemLog" ADD CONSTRAINT "SystemLog_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;
