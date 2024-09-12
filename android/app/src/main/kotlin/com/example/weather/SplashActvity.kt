package com.example.weather

import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import androidx.appcompat.app.AppCompatActivity
import android.view.WindowManager
import android.os.Build
import androidx.core.content.ContextCompat

class SplashActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_splash)

        // Set the status bar color to #00BCD4
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            window.statusBarColor = ContextCompat.getColor(this, R.color.colorPrimaryDark) // Ensure this color exists in colors.xml
        }

        // Delay to simulate a splash screen
        Handler(Looper.getMainLooper()).postDelayed({
            // Start the Flutter MainActivity
            val intent = Intent(this, MainActivity::class.java)
            startActivity(intent)
            finish() // Finish the SplashActivity so it can't be returned to
        }, 2000) // 2000 milliseconds = 2 seconds
    }
}
