<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('shifts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->dateTime('start_time')->nullable();
            $table->dateTime('end_time')->nullable();
            $table->decimal('opening_cash', 15, 2)->default(1000000);
            $table->decimal('cash_revenue', 15, 2)->default(0);
            $table->decimal('bank_revenue', 15, 2)->default(0);
            $table->decimal('closing_cash', 15, 2)->default(0);
            $table->decimal('total_revenue', 15, 2)->default(0);
            $table->unsignedInteger('total_orders')->default(0);
            $table->unsignedInteger('total_products')->default(0);
            $table->string('status')->default('open');
            $table->text('note')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('shifts');
    }
};
