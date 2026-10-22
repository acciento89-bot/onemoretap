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
 def test_marker_overlap_does_not_make_the_stationary_target_move(self):
  with tempfile.TemporaryDirectory() as tmp:
   root=pathlib.Path(tmp);self.frame(root,'clear',100);expected=m.geometry(root,'clear')['target']
   for angle in [13,20]:
    self.frame(root,'overlap',angle)
    with Image.open(root/'overlap.png')as original:
     im=original.convert('RGB');d=ImageDraw.Draw(im);d.arc((116,216,584,684),-8,8,fill=(130,70,230),width=20)
     x,y=350+234*math.cos(math.radians(angle)),450-234*math.sin(math.radians(angle));d.ellipse((x-12,y-12,x+12,y+12),fill='white');im.save(root/'overlap.png')
    self.assertAlmostEqual(m.delta(expected,m.geometry(root,'overlap')['target']),0,delta=0.5)
 def test_actual_target_shift_is_not_mistaken_for_marker_occlusion(self):
  with tempfile.TemporaryDirectory() as tmp:
   root=pathlib.Path(tmp);self.frame(root,'a',100,target=0);self.frame(root,'b',100,target=45)
   self.assertAlmostEqual(m.delta(m.geometry(root,'a')['target'],m.geometry(root,'b')['target']),45,delta=0.5)
 def test_missing_actual_marker_never_passes_as_movement(self):
  with tempfile.TemporaryDirectory() as tmp:
   root=pathlib.Path(tmp);self.frame(root,'a',100);Image.new('RGB',(700,900),(8,5,20)).save(root/'a.png')
   with self.assertRaises(AssertionError):m.geometry(root,'a')
