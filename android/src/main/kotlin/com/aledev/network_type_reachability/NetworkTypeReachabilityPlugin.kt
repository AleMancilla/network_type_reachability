package com.aledev.network_type_reachability

import androidx.annotation.NonNull
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.os.Build
import android.telephony.TelephonyManager
import android.util.Log
import androidx.annotation.RequiresApi
import androidx.core.content.ContextCompat

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result


/** NetworkTypeReachabilityPlugin */
class NetworkTypeReachabilityPlugin: FlutterPlugin, MethodCallHandler,EventChannel.StreamHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var eventChannel: EventChannel
  private lateinit var context: Context
  private lateinit var connectivityManager: ConnectivityManager
  private var broadcastReceiver: NetworkBroadcastReceiver? = null


  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_plugin_reachability")
    channel.setMethodCallHandler(this)

    eventChannel = EventChannel(flutterPluginBinding.binaryMessenger,"flutter_plugin_reachability_status")
    eventChannel.setStreamHandler(this)

    //记录上下文
    context = flutterPluginBinding.applicationContext
    connectivityManager = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager

  }

  @RequiresApi(Build.VERSION_CODES.N)
  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "networkStatus") {
      result.success(getNetworkState(connectivityManager,context))
    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
    //在注册通知
    if (broadcastReceiver == null) {
      broadcastReceiver = NetworkBroadcastReceiver(events,connectivityManager,context)
    }
    val filter = IntentFilter()
    filter.addAction(ConnectivityManager.CONNECTIVITY_ACTION)
    context.registerReceiver(broadcastReceiver,filter)


  }

  override fun onCancel(arguments: Any?) {
    if (broadcastReceiver != null) {
      context.unregisterReceiver(broadcastReceiver);
      broadcastReceiver = null;
    }
  }
}

private  class NetworkBroadcastReceiver(val events: EventChannel.EventSink?,val connectivityManager: ConnectivityManager,val context: Context): BroadcastReceiver() {
  @RequiresApi(Build.VERSION_CODES.N)
  override fun onReceive(p0: Context?, p1: Intent?) {
    print("change in red")
    events?.success(getNetworkState(connectivityManager,context));
  }
}

/*获取网络状态*/
@RequiresApi(Build.VERSION_CODES.N)
private  fun getNetworkState(connectivityManager: ConnectivityManager, context: Context): String {
  if (android.os.Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
    val network = connectivityManager.activeNetwork
    val capabilities = connectivityManager.getNetworkCapabilities(network)
    if (capabilities == null){
      return NetworkState.unReachable.ordinal.toString()
    }
    if (capabilities.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) || capabilities.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET)) {
      return NetworkState.wifi.ordinal.toString()
    }

    if (capabilities.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR)) {
      return getMobileNetworkType(context)
    }
  }else{
    val networkInfo = connectivityManager.activeNetworkInfo
    if (networkInfo == null || !networkInfo.isConnected) {
      return NetworkState.unReachable.ordinal.toString()
    }
    val type = networkInfo.type
    when(type){
      ConnectivityManager.TYPE_ETHERNET,ConnectivityManager.TYPE_WIFI,ConnectivityManager.TYPE_WIMAX -> {
        return NetworkState.wifi.ordinal.toString()
      }
      ConnectivityManager.TYPE_MOBILE,ConnectivityManager.TYPE_MOBILE_DUN,ConnectivityManager.TYPE_MOBILE_HIPRI -> {
        return getMobileNetworkType(context)
      }
      else -> return NetworkState.unReachable.ordinal.toString()
    }
  }
  return NetworkState.unReachable.ordinal.toString()
}

@RequiresApi(Build.VERSION_CODES.N)
private  fun getMobileNetworkType(context: Context): String {
  if (context == null) {
    return NetworkState.moblieOther.ordinal.toString()
  }

  //在这里权限检查
  val ret =  ContextCompat.checkSelfPermission(context,android.Manifest.permission.READ_PHONE_STATE)
  if (ret == PackageManager.PERMISSION_DENIED) {
    return NetworkState.moblieOther.ordinal.toString()
  }

  val telephonyManager = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
  val moblie2G_types = arrayOf(
          TelephonyManager.NETWORK_TYPE_1xRTT,
          TelephonyManager.NETWORK_TYPE_EDGE,
          TelephonyManager.NETWORK_TYPE_GPRS,
          TelephonyManager.NETWORK_TYPE_CDMA,
          TelephonyManager.NETWORK_TYPE_IDEN
  )
  if (telephonyManager.dataNetworkType in moblie2G_types) {
    return NetworkState.moblie2G.ordinal.toString()
  }
  val moblie3G_types = arrayOf(
          TelephonyManager.NETWORK_TYPE_UMTS,
          TelephonyManager.NETWORK_TYPE_EVDO_0,
          TelephonyManager.NETWORK_TYPE_EVDO_A,
          TelephonyManager.NETWORK_TYPE_HSDPA,
          TelephonyManager.NETWORK_TYPE_HSUPA,
          TelephonyManager.NETWORK_TYPE_HSPA,
          TelephonyManager.NETWORK_TYPE_EVDO_B,
          TelephonyManager.NETWORK_TYPE_EHRPD,
          TelephonyManager.NETWORK_TYPE_HSPAP
  )
  if (telephonyManager.dataNetworkType in moblie3G_types) {
    return NetworkState.moblie3G.ordinal.toString()
  }
  if (telephonyManager.dataNetworkType == TelephonyManager.NETWORK_TYPE_LTE) {
    return NetworkState.moblie4G.ordinal.toString()
  }
  if (telephonyManager.dataNetworkType == TelephonyManager.NETWORK_TYPE_NR) {
    return NetworkState.moblie5G.ordinal.toString()
  }
  return NetworkState.moblieOther.ordinal.toString()
}


private enum class NetworkState {
  unReachable,
  moblie2G,
  moblie3G,
  wifi,
  moblie4G,
  moblie5G,
  moblieOther
}
