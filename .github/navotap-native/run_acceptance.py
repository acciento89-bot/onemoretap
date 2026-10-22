"""Actual immutable Release candidate, one owned emulator, explicit local non-purchase fixtures."""
import datetime,hashlib,io,json,os,pathlib,re,subprocess,tarfile,xml.etree.ElementTree as ET
from archive_contract import archive,profile
from motion_contract import validate as validate_motion
APP='com.kamilunavo.onemoretap';HOST=APP+'qa'
FRAMES=['00-home','00-classic','01-drills','02-moving-a','02-moving-b','03-held-a','03-held-b','04-resumed-a','04-resumed-b','05-feedback','06-next-target','07-timing-result','08-repeat-a','08-repeat-b','09-precision-result','10-counterclockwise','11-clockwise','12-direction-result','13-cold-history','14-short-paused','15-protected-archive','16-save-failure','17-retry-saved','18-final-cold']
NATIVE_FILES={n+e for n in FRAMES for e in ['.png','.xml','.time']}|{'audio-playback.txt'}
OPTIONAL_FILES={'failure-screen.png','failure-screen.xml','failure-screen.time'}
GENERIC_FILES={'result.json','source-commit.txt','host-build.log','root-mode.txt','installed-identity.txt','preflight-anr.txt','final-anr.txt','window.txt','logcat.txt','final-screen.png','emulator-stop.txt','avd-delete.txt','remaining-avds.txt','remaining-devices.txt','cleanup.json','cleanup-failed.txt','fixture-manifest.json','fixture-profile.xml','failure-profile.xml','motion-measurements.json','corrupt-archive.json'}|{f'phase{i}-{name}'for i in range(1,7)for name in ['instrumentation.txt','profile.xml','archive.json']}
def reject_anr(data):
 if re.search(rb'ANR in|Application Not Responding|com.android.systemui|com.google.android.apps.nexuslauncher',data,re.I):raise RuntimeError('Observed system/launcher ANR; no dismissal')
def reject_anr_window(data):
 assert re.search(rb'Window\{[^}]+\}',data),'Actual window inventory required'
 assert not re.search(rb'ANR in|Application Not Responding|isn.t responding',data,re.I),'Observed ANR window'
def run():
 runtime=pathlib.Path(os.environ['RUNNER_TEMP']).resolve();proof=runtime/'navotap-native-acceptance/navotap';assert not proof.is_symlink()and not proof.parent.is_symlink();proof.mkdir(parents=True,exist_ok=True,mode=0o700)
 result={'status':'STARTED','package':APP,'version':'1.1.0(8)','realTransactions':False,'fixtureScope':'Fresh workflow-owned emulator only: explicit legacy free-play best17/coins23/neon and normal sound/haptics preferences; no purchased entitlement. Only new practice archive gets controlled future-version and write-failure fixtures.'};validated=False
 def call(args,timeout=20):
  p=subprocess.run(['adb','-s','emulator-5554',*args],stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=timeout)
  if p.returncode:raise RuntimeError('Owned adb command failed: '+args[0])
  return p.stdout
 def owned():assert call(['shell','getprop','ro.build.version.sdk']).strip()==b'35'and call(['shell','getprop','ro.kernel.qemu']).strip()==b'1'
 def instrument(method,index):
  data=call(['shell','am','instrument','-w','-r','-e','class',HOST+'.SkillNativeTest#'+method,HOST+'.test/androidx.test.runner.AndroidJUnitRunner'],900);(proof/f'phase{index}-instrumentation.txt').write_bytes(data)
  assert b'OK (1 test)'in data and not any(x in data for x in [b'FAILURES',b'INSTRUMENTATION_FAILED',b'Process crashed']),'Actual native scenario failed: '+method
 root='/data/user/0/'+APP;pref=root+'/shared_prefs/navotap_profile.xml';folder=root+'/files/NavoTap';file=folder+'/skill-lab.json'
 def snapshot(index,stop=True):
  if stop:call(['shell','am','force-stop',APP])
  p=call(['exec-out','cat',pref]);a=call(['exec-out','cat',file]);assert len(p)<100_000 and len(a)<1_000_000;(proof/f'phase{index}-profile.xml').write_bytes(p);(proof/f'phase{index}-archive.json').write_bytes(a);assert profile(p)==baseline,'Classic values or existing settings changed';return a
 try:
  owned();anr=call(['shell','dumpsys','activity','lastanr']);(proof/'preflight-anr.txt').write_bytes(anr);reject_anr(anr);validated=True
  (proof/'root-mode.txt').write_bytes(call(['root']));call(['wait-for-device'],30);owned();assert call(['shell','id','-u']).strip()==b'0'
  apks=[pathlib.Path('candidate/universal.apk'),pathlib.Path('.github/navotap-native/host/app/build/outputs/apk/debug/app-debug.apk'),pathlib.Path('.github/navotap-native/host/app/build/outputs/apk/androidTest/debug/app-debug-androidTest.apk')];result['apkSha256']={str(p):hashlib.sha256(p.read_bytes()).hexdigest()for p in apks}
  for apk in apks:call(['install','-r',str(apk)],180)
  identity=call(['shell','dumpsys','package',APP]);(proof/'installed-identity.txt').write_bytes(identity);assert re.search(rb'\bversionCode=8(?=\s|$)',identity)and re.search(rb'\bversionName=1\.1\.0(?=\s|$)',identity)
  uid=call(['shell','stat','-c','%u',root]).decode().strip();gid=call(['shell','stat','-c','%g',root]).decode().strip();assert uid.isdecimal()and gid.isdecimal()and int(uid)>=10000
  xml=b'<?xml version="1.0" encoding="utf-8"?><map><int name="classic.bestScore" value="17"/><int name="wallet.coins" value="23"/><boolean name="settings.soundEnabled" value="true"/><boolean name="settings.hapticsEnabled" value="false"/><string name="cosmetics.selectedTheme">neon</string><int name="ads.restartCount" value="1"/></map>'
  baseline=profile(xml);(proof/'fixture-profile.xml').write_bytes(xml);(proof/'fixture-manifest.json').write_text(json.dumps({'ownedFreshEmulatorOnly':True,'premiumFixture':False,'explicitFreeLegacyProfile':baseline,'shippingTestEndpoint':False})+'\n');call(['push',str(proof/'fixture-profile.xml'),'/data/local/tmp/navotap-owned-profile.xml']);call(['shell',f'mkdir -p {root}/shared_prefs && cat /data/local/tmp/navotap-owned-profile.xml > {pref} && chown {uid}:{gid} {root}/shared_prefs {pref} && chmod 700 {root}/shared_prefs && chmod 600 {pref} && restorecon -RF {root}/shared_prefs && rm /data/local/tmp/navotap-owned-profile.xml'])
  instrument('threeDrillsWithRenderedMotion',1);initial=snapshot(1);archive(initial,3)
  instrument('coldAndShortLayout',2);cold=snapshot(2);assert initial==cold,'Cold reopen or short layout changed completed archive'
  corrupt=b'{"schemaVersion":999,"preserve":"owned future archive; do not overwrite"}';(proof/'corrupt-archive.json').write_bytes(corrupt);call(['push',str(proof/'corrupt-archive.json'),'/data/local/tmp/navotap-owned-archive.json']);call(['shell',f'cat /data/local/tmp/navotap-owned-archive.json > {file} && rm /data/local/tmp/navotap-owned-archive.json'])
  instrument('corruptedArchiveIsProtected',3);assert snapshot(3)==corrupt,'Protected future archive overwritten'
  call(['push',str(proof/'phase1-archive.json'),'/data/local/tmp/navotap-owned-archive.json']);call(['shell',f'cat /data/local/tmp/navotap-owned-archive.json > {file} && rm /data/local/tmp/navotap-owned-archive.json && chmod 500 {folder}'])
  instrument('writeFailureRetainsResult',4);assert snapshot(4,stop=False)==initial,'Failed write changed durable archive'
  # Do not kill the process here: its unsaved completed result must survive the retry.
  call(['shell','chmod','700',folder]);instrument('retryWritesOnce',5);saved=snapshot(5);archive(saved,4);old=json.loads(initial)['progress']['recent'];new=json.loads(saved)['progress']['recent'];assert all(row in new for row in old),'Retry altered previous completed results'
  instrument('finalColdHistory',6);assert snapshot(6)==saved,'Final cold reopen changed retried archive'
  result['status']='PASSED'
 except BaseException as e:result.update(status='FAILED',error=str(e))
 finally:
  if validated:
   if result['status']=='FAILED' and 'baseline' in locals():
    try:
     current=call(['exec-out','cat',pref]);assert len(current)<100_000 and set(profile(current))==set(baseline);(proof/'failure-profile.xml').write_bytes(current)
    except BaseException:result.setdefault('diagnostics',{})['failureProfile']='Unavailable or outside exact owned fixture schema'
   for name,args in [('final-screen.png',['exec-out','screencap','-p']),('window.txt',['shell','dumpsys','window','windows']),('logcat.txt',['logcat','-d','-t','2000']),('final-anr.txt',['shell','dumpsys','activity','lastanr'])]:
    try:(proof/name).write_bytes(call(args))
    except BaseException as e:result.setdefault('diagnostics',{})[name]=type(e).__name__
   try:
    reject_anr((proof/'final-anr.txt').read_bytes());reject_anr_window((proof/'window.txt').read_bytes());packed=call(['exec-out','run-as',HOST,'tar','-cf','-','-C','files','native-proof']);assert len(packed)<60*1024*1024;found=set()
    with tarfile.open(fileobj=io.BytesIO(packed))as t:
     for member in t.getmembers():
      if member.isdir():continue
      p=pathlib.PurePosixPath(member.name);assert member.isfile()and p.parent==pathlib.PurePosixPath('native-proof')and p.name in NATIVE_FILES|OPTIONAL_FILES and p.name not in found and member.size<8*1024*1024;found.add(p.name);(proof/p.name).write_bytes(t.extractfile(member).read())
    if result['status']=='PASSED':
     assert found==NATIVE_FILES,'Incomplete actual native proof';measurements=validate_motion(proof);(proof/'motion-measurements.json').write_text(json.dumps(measurements,indent=2)+'\n')
   except BaseException as e:
    result.setdefault('diagnostics',{})['nativeProof']=str(e)
    if result['status']=='PASSED':result.update(status='FAILED',error='Incomplete or invalid actual native proof')
  result['finishedUTC']=datetime.datetime.now(datetime.timezone.utc).isoformat();(proof/'result.json').write_text(json.dumps(result,indent=2)+'\n')
 return result
if __name__=='__main__':
 os.umask(0o077);r=run();print(json.dumps({'status':r['status'],'evidence':'bounded encrypted own synthetic records only'}));raise SystemExit(0 if r['status']=='PASSED'else 1)
