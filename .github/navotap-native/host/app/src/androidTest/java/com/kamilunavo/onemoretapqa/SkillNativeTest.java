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
 private void freshAccessibility(){assertTrue("Owned API35 accessibility cache must clear",InstrumentationRegistry.getInstrumentation().getUiAutomation().clearCache());}
 private UiScrollable nativeScroll(){
  freshAccessibility();
  return new UiScrollable(new UiSelector().packageName(APP).scrollable(true)).setAsVerticalList().setSwipeDeadZonePercentage(.20);
 }
 private boolean scrollPage(boolean forward){
  // Use UI Automator's completed scroll gesture, not a fast fling or a cached
  // label coordinate. Touch targets below must also settle before being tapped.
  try{return forward?nativeScroll().scrollForward(100):nativeScroll().scrollBackward(100);}
  catch(UiObjectNotFoundException missing){return false;}
 }
 private void top(){try{nativeScroll().scrollToBeginning(12,100);}catch(UiObjectNotFoundException missing){/* Non-scrollable Classic screen. */}}
 private UiObject2 find(BySelector selector){
  // A successful hasObject followed by findObjects can span a Compose transition.
  // Poll the actual unique snapshot; absence is transient, ambiguity still fails.
  long until=SystemClock.elapsedRealtime()+1500;
  do {freshAccessibility();List<UiObject2> nodes=device.findObjects(selector);if(nodes.size()==1)return nodes.get(0);if(nodes.size()>1)fail("Ambiguous target "+selector);SystemClock.sleep(25);}while(SystemClock.elapsedRealtime()<until);
  top();for(int n=0;n<25;n++){
   freshAccessibility();List<UiObject2> nodes=device.findObjects(selector);
   if(nodes.size()==1)return nodes.get(0);if(nodes.size()>1)fail("Ambiguous target "+selector);
   // UiScrollable false is not an authoritative end-of-content signal for this
   // Compose viewport. Always inspect the next actual snapshot; never invent a
   // target or use coordinates from an earlier viewport. Search remains bounded.
   boolean reportedMovement=scrollPage(true);
   try(FileWriter out=new FileWriter(new File(proof,"scroll-observations.txt"),true)){
    out.write("target="+selector+" gesture="+n+" reportedMovement="+reportedMovement+"\n");
   }catch(IOException error){throw new AssertionError("Scroll proof must persist",error);}
  }
  fail("Target missing "+selector);return null;
 }
 private UiObject2 touchable(BySelector selector){
  android.graphics.Rect previous=null;int stable=0;
  for(int attempt=0;attempt<24;attempt++){
   UiObject2 n=find(selector);int ancestors=0;
   while(!n.isClickable()&&ancestors++<4){n=n.getParent();assertNotNull("Clickable control required "+selector,n);}
   assertTrue("Clickable target required "+selector,n.isClickable());
   android.graphics.Rect bounds=n.getVisibleBounds();
   if(bounds.height()>=90&&bounds.width()>=90){
    stable=bounds.equals(previous)?stable+1:0;previous=new android.graphics.Rect(bounds);
    if(stable>=2)return n;SystemClock.sleep(100);continue;
   }
   previous=null;stable=0;scrollPage(true);
  }
  fail("Control must be genuinely touchable, not a clipped label: "+selector);return null;
 }
 private void click(BySelector selector){UiObject2 n=touchable(selector);assertTrue("Disabled target "+selector,n.isEnabled());n.click();}
 private void text(String s){click(By.text(s));}
 private void expect(String s){assertNotNull(find(By.text(s)));}
 private void fullRing(){
  UiObject2 node=find(By.desc(RING));
  for(int attempt=0;attempt<8;attempt++){
   android.graphics.Rect r=node.getVisibleBounds();if(r.height()>=r.width()-3)return;
   int h=device.getDisplayHeight();boolean clippedTop=r.top<h*.16;
   scrollPage(!clippedTop);node=find(By.desc(RING));
  }
  fail("Whole ring must fit the real scrollable viewport");
 }
 private void capture(String name)throws Exception {
  freshAccessibility();
  if(!name.equals("failure-screen")){assertEquals(APP,device.getCurrentPackageName());if(!name.equals("14-short-paused")&&device.hasObject(By.desc(RING)))fullRing();}
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
 @Test public void privacyChoicesBeforeGameplay()throws Exception {
  UiObject2 options=device.wait(Until.findObject(By.text("Manage options")),30000);
  String choice="FORM_NOT_SHOWN";
  if(options!=null){
   options.click();
   UiObject2 confirm=device.wait(Until.findObject(By.text("Confirm choices")),15000);
   assertNotNull("The actual privacy preferences must finish opening",confirm);
   List<UiObject2> toggles=device.findObjects(By.clazz("android.widget.ToggleButton"));
   assertFalse("Privacy preferences must expose their default choices",toggles.isEmpty());
   for(UiObject2 toggle:toggles)assertFalse("Never grant consent during acceptance",toggle.isChecked());
   confirm.click();assertTrue(device.wait(Until.gone(By.text("Manage your data")),10000));
   choice="CONFIRMED_EXISTING_DEFAULTS_OFF";
  }
  expect("Sound");capture("00-privacy-choice");
  try(FileWriter out=new FileWriter(new File(proof,"privacy-choice.txt"))){out.write(choice+"\n");}
 }
 @Test public void muteBeforeColdRestart()throws Exception {
  audioCount(1);text("Sound");audioCount(0);
 }
 @Test public void threeDrillsWithRenderedMotion()throws Exception {
  // The external controller has verified the actual durable preference and killed
  // the real non-debuggable app. This newly launched process must stay silent.
  expect("Sound");audioCount(0);
  text("Sound");audioCount(1);
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
  device.executeShellCommand("wm size 1080x1350");expect("Resume");
  text("Resume");expect("Pause");text("Pause");expect("Paused. Resume when ready.");
  touchable(By.text("Resume"));capture("14-short-paused");
  device.executeShellCommand("wm size reset");expect("Resume");text("Back to drills");
 }
 @Test public void corruptedArchiveIsProtected()throws Exception {
  text("SKILL LAB");expect("Practice data could not be loaded. Its file is preserved; saving is blocked.");
  // Compose exposes the semantic label as an enabled child; the actual
  // clickable Button ancestor carries Disabled. Verify that control itself.
  for(String title:new String[]{"Steady timing","Precision","Direction changes"}){
   UiObject2 button=find(By.desc("Start 12 attempts: "+title)).getParent();
   assertTrue("Actual clickable drill control: "+title,button.isClickable());
   assertFalse("Protected archive must disable the actual drill control: "+title,button.isEnabled());
   button.click();assertFalse("Disabled control must not start a trial",device.hasObject(By.desc(RING)));
  }
  capture("15-protected-archive");
 }
 @Test public void writeFailureRetainsResult()throws Exception {
  text("SKILL LAB");start("Steady timing");
  for(int trial=1;trial<=12;trial++){expect("Attempt "+trial+"/12");click(By.desc(RING));if(trial<12){expect("Next attempt");text("Next attempt");}}
  expect("Saving failed. Your result remains here; retry below.");expect("Save result");capture("16-save-failure");
 }
 @Test public void retryWritesOnce()throws Exception {
  // Phase4 already observed the real failure banner and root-checked unchanged
  // durable bytes. Retry the retained result via its actual enabled control.
  expect("Save result");text("Save result");expect("Saved on this device");assertFalse(device.hasObject(By.text("Save result")));capture("17-retry-saved");menu();
 }
 @Test public void finalColdHistory()throws Exception {text("SKILL LAB");expect("Recent practice");capture("18-final-cold");}
}
