"""A download recovery may change delivery helpers, never the shipped product source."""
import pathlib,re,subprocess
PRODUCT_PATHS=['android/app/src/main','android/app/build.gradle.kts','android/build.gradle.kts','android/settings.gradle.kts','android/gradle.properties','OneMoreTap/Assets.xcassets/AppIcon.appiconset/AppIcon.png']
def assert_same_product(root:pathlib.Path,old:str,new:str):
 assert re.fullmatch('[0-9a-f]{40}',old)and re.fullmatch('[0-9a-f]{40}',new),'Exact commit IDs required'
 assert subprocess.run(['git','-C',str(root),'merge-base','--is-ancestor',old,new],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL).returncode==0,'Candidate source must be an ancestor'
 assert subprocess.run(['git','-C',str(root),'diff','--quiet',old,new,'--',*PRODUCT_PATHS],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL).returncode==0,'Product source changed'
