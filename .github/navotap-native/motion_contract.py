"""Measure actual white Canvas marker and colored target, never engine/model telemetry."""
import math,pathlib,re,xml.etree.ElementTree as ET
RING='Tap the moving marker at the target'
def geometry(folder:pathlib.Path,stem:str):
 from PIL import Image
 root=ET.parse(folder/(stem+'.xml')).getroot();nodes=[e for e in root.iter('node')if e.get('content-desc')==RING];assert len(nodes)==1,'Unique actual Canvas accessibility bounds required'
 x0,y0,x1,y1=map(int,re.fullmatch(r'\[(\d+),(\d+)\]\[(\d+),(\d+)\]',nodes[0].get('bounds')) .groups());w=x1-x0;h=y1-y0;assert w>300 and abs(w-h)<=2,'Whole square Canvas must be visible'
 with Image.open(folder/(stem+'.png'))as image:
  cx,cy=(x0+x1)/2,(y0+y1)/2;radius=w*.39;marker=[];target=[]
  for y in range(y0,y1):
   for x in range(x0,x1):
    distance=math.hypot(x-cx,y-cy)
    if abs(distance-radius)>w*.035:continue
    r,g,b=image.getpixel((x,y))[:3]
    if min(r,g,b)>230:marker.append((x,y))
    elif (g>100 and b>100 and r<60)or(b>130 and r>70 and g<160):target.append((x,y))
  assert len(marker)>40 and len(target)>40,'Actual bright marker and colored target pixels required'
  def centroid(points):return(sum(x for x,y in points)/len(points),sum(y for x,y in points)/len(points))
  def angle(point):return math.degrees(math.atan2(cy-point[1],point[0]-cx))%360
  return {'marker':angle(centroid(marker)),'target':angle(centroid(target)),'markerPixels':len(marker),'targetPixels':len(target),'bounds':[x0,y0,x1,y1]}
def delta(a,b):return(b-a+180)%360-180
def validate(folder:pathlib.Path):
 result={}
 for prefix,moving in [('02-moving',True),('03-held',False),('04-resumed',True),('08-repeat',True)]:
  a=geometry(folder,prefix+'-a');b=geometry(folder,prefix+'-b');elapsed=int((folder/(prefix+'-b.time')).read_text())-int((folder/(prefix+'-a.time')).read_text());assert elapsed>=(500 if not moving else 250),'Real sampling interval required'
  distance=abs(delta(a['marker'],b['marker']));assert (distance>5 if moving else distance<1),'Rendered marker did not match pause/movement state';assert abs(delta(a['target'],b['target']))<1,'Target moved within one trial'
  result[prefix]={'a':a,'b':b,'elapsedMs':elapsed,'markerAngleChange':distance}
 before=geometry(folder,'02-moving-a');after=geometry(folder,'06-next-target');assert abs(delta(before['target'],after['target']))>10,'Next attempt did not redraw the target'
 ccw=geometry(folder,'10-counterclockwise');cw=geometry(folder,'11-clockwise');assert abs(delta(ccw['target'],cw['target']))>10
 result['nextTargetChange']=abs(delta(before['target'],after['target']));return result
