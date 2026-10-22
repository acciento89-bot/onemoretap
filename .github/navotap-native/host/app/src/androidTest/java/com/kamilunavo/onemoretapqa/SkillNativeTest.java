package com.kamilunavo.onemoretapqa;

import android.content.Intent;
import android.os.Build;
import android.os.SystemClock;
import android.view.accessibility.AccessibilityWindowInfo;
import androidx.test.ext.junit.runners.AndroidJUnit4;
import androidx.test.platform.app.InstrumentationRegistry;
import androidx.test.uiautomator.*;
import org.junit.*;
import org.junit.rules.TestWatcher;
import org.junit.runner.Description;
import org.junit.runner.RunWith;
import java.io.*;
import java.util.*;
import static org.junit.Assert.*;

/** External host only: real installed candidate, real touch/Canvas, no production test endpoints. */
@RunWith(AndroidJUnit4.class)
public final class SkillNativeTest {
 private static final String APP="com.kamilunavo.onemoretap";
 private static final String RING="Tap the moving marker at the target";
 private final UiDevice device=UiDevice.getInstance(InstrumentationRegistry.getInstrumentation());
 private final android.content.Context host=InstrumentationRegistry.getInstrumentation().getTargetContext();
 private final File proof=new File(host.getFilesDir(),"native-proof");
 @Rule public final TestWatcher watcher=new TestWatcher(){@Override protected void failed(Throwable e,Description d){try{capture("failure-screen");}catch(Exception ignored){}}};
 @Before public void owned()throws Exception {
  assertEquals(35,Build.VERSION.SDK_INT);assertEquals("1",device.executeShellCommand("getprop ro.kernel.qemu").trim());proof.mkdirs();
  Configurator.getInstance().setWaitForIdleTimeout(100).setWaitForSelectorTimeout(100);
  android.accessibilityservice.AccessibilityServiceInfo info=InstrumentationRegistry.getInstrumentation().getUiAutomation().getServiceInfo();assertNotNull(info);info.flags|=android.accessibilityservice.AccessibilityServiceInfo.FLAG_RETRIEVE_INTERACTIVE_WINDOWS;InstrumentationRegistry.getInstrumentation().getUiAutomation().setServiceInfo(info);
  if(!APP.equals(device.getCurrentPackageName()))launch();
 }
 private void launch(){Intent i=host.getPackageManager().getLaunchIntentForPackage(APP);assertNotNull(i);host.startActivity(i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK));assertTrue(device.wait(Until.hasObject(By.pkg(APP)),20000));}
 private void top(){for(int n=0;n<10;n++)device.swipe(device.getDisplayWidth()/2,(int)(device.getDisplayHeight()*.3),device.getDisplayWidth()/2,(int)(device.getDisplayHeight()*.8),15);}
 private UiObject2 find(BySelector selector){
  if(device.wait(Until.hasObject(selector),1500)){List<UiObject2> nodes=device.findObjects(selector);assertEquals("Unique visible target: "+selector,1,nodes.size());return nodes.get(0);}
  top();for(int n=0;n<25;n++){List<UiObject2> nodes=device.findObjects(selector);if(nodes.size()==1)return nodes.get(0);if(nodes.size()>1)fail("Ambiguous target "+selector);device.swipe(device.getDisplayWidth()/2,(int)(device.getDisplayHeight()*.78),device.getDisplayWidth()/2,(int)(device.getDisplayHeight()*.28),20);}
  fail("Target missing "+selector);return null;
 }
 private void click(BySelector selector){UiObject2 n=find(selector);assertTrue("Disabled target "+selector,n.isEnabled());n.click();}
 private void text(String s){click(By.text(s));}
 private void expect(String s){assertNotNull(find(By.text(s)));}
 private void fullRing(){
  UiObject2 node=find(By.desc(RING));
  for(int attempt=0;attempt<8;attempt++){
   android.graphics.Rect r=node.getVisibleBounds();if(r.height()>=r.width()-3)return;
   int h=device.getDisplayHeight();boolean clippedTop=r.top<h*.16;
   device.swipe(device.getDisplayWidth()/2,(int)(h*(clippedTop?.3:.72)),device.getDisplayWidth()/2,(int)(h*(clippedTop?.62:.42)),20);node=find(By.desc(RING));
  }
  fail("Whole ring must fit the real scrollable viewport");
 }
 private void capture(String name)throws Exception {
  if(!name.equals("failure-screen")){assertEquals(APP,device.getCurrentPackageName());if(device.hasObject(By.desc(RING)))fullRing();}
  assertTrue(device.takeScreenshot(new File(proof,name+".png")));device.dumpWindowHierarchy(new File(proof,name+".xml"));
  try(FileWriter out=new FileWriter(new File(proof,name+".time"))){out.write(Long.toString(SystemClock.elapsedRealtime()));}
 }
 private void pair(String prefix,long gap)throws Exception {find(By.desc(RING));capture(prefix+"-a");SystemClock.sleep(gap);capture(prefix+"-b");}
 private void menu(){text("Back to drills");expect("Steady timing");}
 private void start(String title){click(By.desc("Start 12 attempts: "+title));expect(title);expect("Attempt 1/12");}
 private void finish(String title,int first)throws Exception {
  for(int trial=first;trial<=12;trial++){
   expect("Attempt "+trial+"/12");click(By.desc(RING));
   if(trial<12){expect("Next attempt");text("Next attempt");expect("Attempt "+(trial+1)+"/12");}
  }
  expect(title+" complete");expect("Saved on this device");
 }
 private void audioCount(int expected)throws Exception {
  android.media.AudioManager am=host.getSystemService(android.media.AudioManager.class);long limit=SystemClock.elapsedRealtime()+6000;int count;
  do {count=0;for(android.media.AudioPlaybackConfiguration c:am.getActivePlaybackConfigurations())if(c.getAudioAttributes().getUsage()==android.media.AudioAttributes.USAGE_GAME)count++;if(count==expected)break;SystemClock.sleep(50);}while(SystemClock.elapsedRealtime()<limit);
  assertEquals("Actual active game music count",expected,count);
  try(FileWriter out=new FileWriter(new File(proof,"audio-playback.txt"),true)){out.write("elapsed="+SystemClock.elapsedRealtime()+" expected="+expected+" actual="+count+"\n");}
 }
 @Test public void threeDrillsWithRenderedMotion()throws Exception {
  audioCount(1);text("Sound");audioCount(0);text("Sound");audioCount(1);
  device.pressHome();assertTrue(device.wait(Until.gone(By.pkg(APP)),10000));audioCount(0);launch();audioCount(1);
  top();capture("00-home");text("CLASSIC");capture("00-classic");device.pressBack();expect("SKILL LAB");
  text("SKILL LAB");expect("Practice only. Classic records, coins and ad continues stay separate. Only completed results are saved on this device.");capture("01-drills");
  start("Steady timing");pair("02-moving",250);
  text("Pause");expect("Paused. Resume when ready.");pair("03-held",500);
  text("Resume");expect("Pause");pair("04-resumed",250);
  click(By.desc(RING));expect("Next attempt");capture("05-feedback");
  text("Next attempt");expect("Attempt 2/12");capture("06-next-target");
  finish("Steady timing",2);top();capture("07-timing-result");
  text("Repeat drill");expect("Attempt 1/12");pair("08-repeat",250);menu();
  start("Precision");finish("Precision",1);top();capture("09-precision-result");menu();
  start("Direction changes");expect("Counterclockwise ↺");capture("10-counterclockwise");click(By.desc(RING));expect("Next attempt");text("Next attempt");expect("Clockwise ↻");capture("11-clockwise");
  finish("Direction changes",2);top();capture("12-direction-result");menu();
 }
 @Test public void coldAndShortLayout()throws Exception {
  text("SKILL LAB");expect("Recent practice");capture("13-cold-history");
  start("Precision");text("Pause");expect("Paused. Resume when ready.");
  device.executeShellCommand("wm size 1080x1350");expect("Resume");capture("14-short-paused");
  device.executeShellCommand("wm size reset");expect("Resume");text("Back to drills");
 }
 @Test public void corruptedArchiveIsProtected()throws Exception {
  text("SKILL LAB");expect("Practice data could not be loaded. Its file is preserved; saving is blocked.");
  for(String title:new String[]{"Steady timing","Precision","Direction changes"})assertFalse(find(By.desc("Start 12 attempts: "+title)).isEnabled());capture("15-protected-archive");
 }
 @Test public void writeFailureRetainsResult()throws Exception {
  text("SKILL LAB");start("Steady timing");
  for(int trial=1;trial<=12;trial++){expect("Attempt "+trial+"/12");click(By.desc(RING));if(trial<12){expect("Next attempt");text("Next attempt");}}
  expect("Saving failed. Your result remains here; retry below.");expect("Save result");capture("16-save-failure");
 }
 @Test public void retryWritesOnce()throws Exception {
  expect("Saving failed. Your result remains here; retry below.");text("Save result");expect("Saved on this device");assertFalse(device.hasObject(By.text("Save result")));capture("17-retry-saved");menu();
 }
 @Test public void finalColdHistory()throws Exception {text("SKILL LAB");expect("Recent practice");capture("18-final-cold");}
}
