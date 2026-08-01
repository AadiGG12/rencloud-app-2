package com.rencloud.app

import android.app.Application
import dagger.hilt.android.HiltAndroidApp

@HiltAndroidApp
class RenCloudApp : Application() {
    override fun onCreate() {
        super.onCreate()
    }
}
