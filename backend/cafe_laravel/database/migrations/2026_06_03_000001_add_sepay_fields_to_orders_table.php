<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            if (!Schema::hasColumn('orders', 'payment_method')) {
                $table->string('payment_method')->nullable()->after('status');
            }

            if (!Schema::hasColumn('orders', 'sepay_code')) {
                $table->string('sepay_code')->nullable()->unique()->after('payment_method');
            }

            if (!Schema::hasColumn('orders', 'sepay_transaction_id')) {
                $table->string('sepay_transaction_id')->nullable()->unique()->after('sepay_code');
            }

            if (!Schema::hasColumn('orders', 'paid_at')) {
                $table->timestamp('paid_at')->nullable()->after('sepay_transaction_id');
            }
        });
    }

    public function down(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            if (Schema::hasColumn('orders', 'paid_at')) {
                $table->dropColumn('paid_at');
            }

            if (Schema::hasColumn('orders', 'sepay_transaction_id')) {
                $table->dropUnique(['sepay_transaction_id']);
                $table->dropColumn('sepay_transaction_id');
            }

            if (Schema::hasColumn('orders', 'sepay_code')) {
                $table->dropUnique(['sepay_code']);
                $table->dropColumn('sepay_code');
            }
        });
    }
};
