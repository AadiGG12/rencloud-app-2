package com.rencloud.app.ui.components

import androidx.compose.foundation.Image
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import com.rencloud.app.R

/**
 * RenCloud brand logo using the real PNG asset.
 */
@Composable
fun RenCloudLogo(
    modifier: Modifier = Modifier,
    contentScale: ContentScale = ContentScale.Fit
) {
    Image(
        painter = painterResource(id = R.drawable.rencloud_logo),
        contentDescription = "RenCloud",
        modifier = modifier,
        contentScale = contentScale
    )
}
