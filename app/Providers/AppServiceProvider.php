<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        // Configurar paths para Vercel
        if (isset($_ENV['VERCEL'])) {
            config([
                'view.compiled' => '/tmp/storage/framework/views',
                'cache.stores.file.path' => '/tmp/storage/framework/cache',
                'session.files' => '/tmp/storage/framework/sessions',
            ]);
        }
    }
}