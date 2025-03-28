<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome'); // Asegúrate de tener resources/views/welcome.blade.php
})->name('home');

