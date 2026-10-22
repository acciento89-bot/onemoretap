"""Actual release payload gate for the Google-reported obsolete Fragment SDK."""
import pathlib,zipfile
FRAGMENT='1.9.1'
def verify_fragment(bundle:pathlib.Path):
 with zipfile.ZipFile(bundle)as z:
  actual=z.read('base/root/META-INF/androidx.fragment_fragment.version').decode().strip()
  assert actual==FRAGMENT,'Actual AndroidX Fragment '+actual+' must be '+FRAGMENT
 return actual
if __name__=='__main__':
 import sys
 print('Actual AndroidX Fragment '+verify_fragment(pathlib.Path(sys.argv[1])))
