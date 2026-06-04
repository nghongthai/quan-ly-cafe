<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('shifts')) {
            return;
        }

        Schema::table('shifts', function (Blueprint $table) {
            if (!Schema::hasColumn('shifts', 'cash_revenue')) {
                $table->decimal('cash_revenue', 15, 2)->default(0)->after('opening_cash');
            }
            if (!Schema::hasColumn('shifts', 'bank_revenue')) {
                $table->decimal('bank_revenue', 15, 2)->default(0)->after('cash_revenue');
            }
            if (!Schema::hasColumn('shifts', 'total_products')) {
                $table->unsignedInteger('total_products')->default(0)->after('total_orders');
            }
            if (!Schema::hasColumn('shifts', 'status')) {
                $table->string('status')->default('closed')->after('total_products');
            }
        });
    }

    public function down(): void
    {
        if (!Schema::hasTable('shifts')) {
            return;
        }

        Schema::table('shifts', function (Blueprint $table) {
            foreach (['cash_revenue', 'bank_revenue', 'total_products', 'status'] as $column) {
                if (Schema::hasColumn('shifts', $column)) {
                    $table->dropColumn($column);
                }
            }
        });
    }
};
