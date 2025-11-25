package com.example.pill_check_app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import org.json.JSONArray

/**
 * 홈 위젯 Provider
 * Small, Medium, Large 3가지 사이즈를 지원합니다.
 */
class PillCheckWidgetProvider : AppWidgetProvider() {

    companion object {
        // home_widget 패키지는 flutter_shared_preferences를 사용하므로
        // FlutterSharedPreferences를 통해 접근해야 합니다.
        // 또는 자체 SharedPreferences를 사용할 수 있습니다.
        // 일반적으로 flutter_shared_preferences는 "FlutterSharedPreferences" 이름을 사용합니다.
        private const val PREFS_NAME = "FlutterSharedPreferences"
        private const val PREFIX_KEY = "flutter."
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        // 각 위젯 ID에 대해 업데이트
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        
        // 위젯 업데이트 요청 처리
        if (intent.action == AppWidgetManager.ACTION_APPWIDGET_UPDATE) {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(
                android.content.ComponentName(context, PillCheckWidgetProvider::class.java)
            )
            onUpdate(context, appWidgetManager, appWidgetIds)
        }
    }

    private fun updateAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        // 위젯 크기에 따라 다른 레이아웃 사용
        val widgetInfo = appWidgetManager.getAppWidgetInfo(appWidgetId)
        val layoutId = when (widgetInfo?.minWidth) {
            in 0..110 -> {
                // Small 위젯
                R.layout.widget_small
            }
            in 111..250 -> {
                // Medium 위젯
                R.layout.widget_medium
            }
            else -> {
                // Large 위젯
                R.layout.widget_large
            }
        }
        
        val views = RemoteViews(context.packageName, layoutId)
        
        // Flutter에서 저장한 데이터 읽기
        // home_widget 패키지는 "HomeWidgetPreferences" SharedPreferences를 사용하고
        // 키는 접두사 없이 직접 사용됩니다 (예: "pill_count", "pills" 등)
        val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        
        // 모든 키 확인 (디버깅용)
        val allKeys = prefs.all.keys
        android.util.Log.d("WidgetProvider", "Available keys: ${allKeys.joinToString()}")
        
        // 키 접두사 없이 직접 사용
        val pillCount = prefs.getString("pill_count", "0") ?: "0"
        val checkedCount = prefs.getString("checked_count", "0") ?: "0"
        val totalRequired = prefs.getString("total_required", "0") ?: "0"
        val intakeRate = prefs.getString("intake_rate", "0.0") ?: "0.0"
        
        // 영양제 목록 가져오기
        val pillsJson = prefs.getString("pills", "[]") ?: "[]"
        val checkedPillsJson = prefs.getString("checked_pills", "[]") ?: "[]"
        
        android.util.Log.d("WidgetProvider", "Pills JSON: $pillsJson")
        android.util.Log.d("WidgetProvider", "Checked pills JSON: $checkedPillsJson")
        
        try {
            val pillsArray = JSONArray(pillsJson)
            val checkedPillsArray = JSONArray(checkedPillsJson)
            val checkedPillsSet = mutableSetOf<String>()
            
            for (i in 0 until checkedPillsArray.length()) {
                checkedPillsSet.add(checkedPillsArray.getString(i))
            }
            
            // 위젯 크기에 따라 다른 내용 표시
            when (layoutId) {
                R.layout.widget_small -> {
                    // Small 위젯: 간단한 정보만
                    val content = if (pillsArray.length() > 0) {
                        val firstPill = pillsArray.getJSONObject(0)
                        val pillName = firstPill.getString("name")
                        val isChecked = checkedPillsSet.contains(firstPill.getString("id"))
                        "$pillName: ${if (isChecked) "✓" else "○"}"
                    } else {
                        "등록된 영양제 없음"
                    }
                    views.setTextViewText(R.id.widget_content, content)
                }
                R.layout.widget_medium -> {
                    // Medium 위젯: 영양제 목록
                    val content = buildString {
                        for (i in 0 until minOf(pillsArray.length(), 5)) {
                            val pill = pillsArray.getJSONObject(i)
                            val pillName = pill.getString("name")
                            val isChecked = checkedPillsSet.contains(pill.getString("id"))
                            append("${if (isChecked) "✓" else "○"} $pillName")
                            if (i < minOf(pillsArray.length(), 5) - 1) {
                                append("\n")
                            }
                        }
                        if (pillsArray.length() == 0) {
                            append("등록된 영양제 없음")
                        }
                    }
                    views.setTextViewText(R.id.widget_content, content)
                }
                R.layout.widget_large -> {
                    // Large 위젯: 영양제 목록 + 복용률
                    val content = buildString {
                        for (i in 0 until pillsArray.length()) {
                            val pill = pillsArray.getJSONObject(i)
                            val pillName = pill.getString("name")
                            val isChecked = checkedPillsSet.contains(pill.getString("id"))
                            append("${if (isChecked) "✓" else "○"} $pillName")
                            if (i < pillsArray.length() - 1) {
                                append("\n")
                            }
                        }
                        if (pillsArray.length() == 0) {
                            append("등록된 영양제 없음")
                        }
                    }
                    views.setTextViewText(R.id.widget_content, content)
                    
                    // 복용률 표시
                    val ratePercent = (intakeRate.toFloatOrNull() ?: 0f * 100).toInt()
                    views.setTextViewText(R.id.widget_chart, "복용률: $ratePercent% ($checkedCount/$totalRequired)")
                }
            }
        } catch (e: Exception) {
            // JSON 파싱 오류 시 기본 메시지 표시
            views.setTextViewText(R.id.widget_content, "데이터 로딩 중...")
        }
        
        // 위젯 업데이트
        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
}

