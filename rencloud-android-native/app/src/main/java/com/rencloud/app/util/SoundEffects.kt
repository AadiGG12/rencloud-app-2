package com.rencloud.app.util

import android.media.AudioManager
import android.media.ToneGenerator
import android.view.SoundEffectConstants
import android.view.View

object SoundEffects {
    private var toneGenerator: ToneGenerator? = null

    fun playClickSound(view: View) {
        try {
            view.playSoundEffect(SoundEffectConstants.CLICK)
        } catch (e: Exception) {
            playThemeToggleSound()
        }
    }

    fun playThemeToggleSound() {
        try {
            if (toneGenerator == null) {
                toneGenerator = ToneGenerator(AudioManager.STREAM_SYSTEM, 60)
            }
            toneGenerator?.startTone(ToneGenerator.TONE_PROP_BEEP, 80)
        } catch (e: Exception) {}
    }
}
