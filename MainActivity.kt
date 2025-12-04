package com.example.botanicka

import android.Manifest
import android.content.pm.PackageManager
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import org.osmdroid.config.Configuration
import org.osmdroid.util.GeoPoint
import org.osmdroid.views.MapView
import org.osmdroid.views.overlay.Marker
import org.osmdroid.views.overlay.mylocation.GpsMyLocationProvider
import org.osmdroid.views.overlay.mylocation.MyLocationNewOverlay

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.drawable.BitmapDrawable



class MainActivity : AppCompatActivity() {


    private fun createNumberIcon(number: Int, color: Int): Bitmap {
        val size = 90
        val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)

        val paintCircle = Paint().apply {
            this.color = color
            isAntiAlias = true
        }

        val paintText = Paint().apply {
            this.color = Color.WHITE
            textSize = 40f
            textAlign = Paint.Align.CENTER
            isAntiAlias = true
        }

        canvas.drawCircle(size / 2f, size / 2f, size / 2.5f, paintCircle)
        canvas.drawText(
            number.toString(),
            size / 2f,
            size / 1.6f,
            paintText
        )

        return bitmap
    }



    private lateinit var map: MapView
    private lateinit var myLocationOverlay: MyLocationNewOverlay
    private val requestCode = 100

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        Configuration.getInstance().userAgentValue = packageName
        setContentView(R.layout.activity_main)

        map = findViewById(R.id.mapView)
        map.setMultiTouchControls(true)

        // 27 GPS BODOV
        val points = listOf(
            GeoPoint(51.227659,5.878646),
            GeoPoint(51.227607,5.878581),
            GeoPoint(51.227526,5.878704),
            GeoPoint(51.227485,5.878560),
            GeoPoint(51.227332,5.878066),
            GeoPoint(51.227420,5.878122),
            GeoPoint(51.227514,5.878045),
            GeoPoint(51.227563,5.878024),
            GeoPoint(51.227661,5.877970),
            GeoPoint(51.227332,5.877538),
            GeoPoint( 51.227256,5.877768),
            GeoPoint(51.226931,5.877571),
            GeoPoint(51.226928,5.877351),
            GeoPoint(51.227012,5.877274),
            GeoPoint(51.226732,5.876960),
            GeoPoint(51.226732,5.876960),
            GeoPoint(51.226835,5.877004),
            GeoPoint(51.226940,5.876684),
            GeoPoint( 51.227025,5.876734),
            GeoPoint(51.227019,5.876840),
            GeoPoint(51.227147,5.876948),
            GeoPoint(51.227035,5.876614),
            GeoPoint(51.227100,5.876619),
            GeoPoint(51.227266,5.876771),
            GeoPoint(51.227406,5.876712),
            GeoPoint(51.227361,5.877025),
            GeoPoint(51.227463,5.877290)
        )

        val infoTexts = listOf(
            "Cornus controversa Variegata",
            "Sciadopitys verticillata Wiel's Beauty",
            "Cedrus atlantica Glauca",
            "Camellia japonica",
            "Ginkgo biloba China Pendula",
            "Acer japonica Orange Dream",
            "Ginkgo biloba Mariken",
            "Cedrus deodara Aurea",
            "Cedrus atlantica Glauca Pendula",
            "Sequoiadendron giganteum",
            "Sequoia sempervirens Loma Prieta Spike ",
            "Pinus sabiniana Isabella",
            "Dr. Elwin Orton ",
            "Liquidambar styraciflua",
            "Magnolia x Coral Lake",
            "Magnolia grandiflora Kay Parris ",
            "Pinus nigra",
            "Liriodendron tulipifera",
            "Sequoia sempervirens Winter Blue",
            "Abies koreana Kosmos",
            "Sequoia sempervirens Xeno",
            "Abies vejarii Mountain Blue",
            "Magnolia denudata Yellow River",
            "Fagus sylvatica Black Swan",
            "Quercus frainetto",
            "Platanus x acerifolia",
            "Cedrus atlantica Glauca"
        )

        val colors = listOf(
            Color.RED,
            Color.BLUE,
            Color.GREEN,
            Color.YELLOW,
            Color.MAGENTA,
            Color.CYAN,
            Color.DKGRAY,
            Color.rgb(255, 128, 0),
            Color.rgb(128, 0, 255),
            Color.rgb(0, 150, 136),
            Color.rgb(244, 67, 54),
            Color.rgb(63, 81, 181),
            Color.rgb(76, 175, 80),
            Color.rgb(255, 152, 0),
            Color.rgb(121, 85, 72),
            Color.rgb(158, 158, 158),
            Color.rgb(33, 150, 243),
            Color.rgb(0, 188, 212),
            Color.rgb(205, 220, 57),
            Color.rgb(139, 195, 74),
            Color.rgb(96, 125, 139),
            Color.rgb(233, 30, 99),
            Color.rgb(103, 58, 183),
            Color.rgb(255, 193, 7),
            Color.rgb(0, 0, 0),
            Color.rgb(255, 87, 34),
            Color.rgb(0, 200, 83)
        )


        map.controller.setZoom(17.0)
        map.controller.setCenter(points[0])




        // Marker overlay
        for (i in points.indices) {
            val marker = Marker(map)
            marker.position = points[i]

            marker.title ="${i + 1 }. " + infoTexts[i]             // názov markeru
            //marker.subDescription = infoTexts[i]        // text po kliknutí

            val markerColor = colors[i % colors.size]

            // vytvorenie ikonky s číslom AJ farbou
            marker.icon = BitmapDrawable(resources, createNumberIcon(i + 1, markerColor))

            marker.setAnchor(Marker.ANCHOR_CENTER, Marker.ANCHOR_BOTTOM)

            marker.setOnMarkerClickListener { m, _ ->
                m.showInfoWindow()
                true
            }

            map.overlays.add(marker)
        }

        checkPermissions()
        enableUserLocation()
    }

    // 🔵 aktivácia sledovania polohy používateľa
    private fun enableUserLocation() {
        myLocationOverlay = MyLocationNewOverlay(GpsMyLocationProvider(this), map)
        myLocationOverlay.enableMyLocation() // získava GPS
        myLocationOverlay.enableFollowLocation() // kamera sleduje používateľa

        map.overlays.add(myLocationOverlay)
    }

    private fun checkPermissions() {
        val permissions = arrayOf(
            Manifest.permission.ACCESS_FINE_LOCATION,
            Manifest.permission.ACCESS_COARSE_LOCATION
        )

        val needPermission = permissions.any {
            ContextCompat.checkSelfPermission(this, it) != PackageManager.PERMISSION_GRANTED
        }

        if (needPermission) {
            ActivityCompat.requestPermissions(this, permissions, requestCode)
        }
    }
}
