package com.kamilunavo.onemoretap

import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.weight
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp

@Composable
fun ScreenHeader(title: String, onBack: () -> Unit) {
    Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
        TextButton(
            onClick = onBack,
            colors = ButtonDefaults.textButtonColors(contentColor = MaterialTheme.colorScheme.primary),
        ) {
            Text("BACK", fontWeight = FontWeight.Bold)
        }
        Spacer(Modifier.weight(1f))
        Text(
            title,
            color = Color.White,
            fontSize = 27.sp,
            fontWeight = FontWeight.Black,
            letterSpacing = 1.2.sp,
        )
    }
}
