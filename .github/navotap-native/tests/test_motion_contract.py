import importlib.util,pathlib,tempfile,unittest,math
try:
 from PIL import Image,ImageDraw
except ImportError:
 Image=None
s=importlib.util.spec_from_file_location('m',pathlib.Path(__file__).resolve().parents[1]/'motion_contract.py');m=importlib.util.module_from_spec(s);s.loader.exec_module(m)
@unittest.skipUnless(Image,'Pillow installed by the explicit native workflow')
class MotionContract(unittest.TestCase):
 def frame(self,root,name,angle,target=0):
  im=Image.new('RGB',(700,900),(8,5,20));d=ImageDraw.Draw(im);cx,cy,r=350,450,234
  d.arc((cx-r,cy-r,cx+r,cy+r),-target-20,-target+20,fill=(0,170,170),width=18)
  x,y=cx+r*math.cos(math.radians(angle)),cy-r*math.sin(math.radians(angle));d.ellipse((x-12,y-12,x+12,y+12),fill='white');im.save(root/(name+'.png'));(root/(name+'.xml')).write_text('<hierarchy><node content-desc="'+m.RING+'" bounds="[50,150][650,750]"/></hierarchy>')
 def test_actual_pixels_resolve_white_marker_and_distinct_target(self):
  with tempfile.TemporaryDirectory() as tmp:
   root=pathlib.Path(tmp);self.frame(root,'a',100);self.frame(root,'b',135);a=m.geometry(root,'a');b=m.geometry(root,'b');self.assertAlmostEqual(m.delta(a['marker'],b['marker']),35,delta=1);self.assertAlmostEqual(m.delta(a['target'],b['target']),0,delta=0.1)
   self.frame(root,'held',135);self.assertAlmostEqual(m.delta(b['marker'],m.geometry(root,'held')['marker']),0,delta=0.1)
 def test_missing_actual_marker_never_passes_as_movement(self):
  with tempfile.TemporaryDirectory() as tmp:
   root=pathlib.Path(tmp);self.frame(root,'a',100);Image.new('RGB',(700,900),(8,5,20)).save(root/'a.png')
   with self.assertRaises(AssertionError):m.geometry(root,'a')
