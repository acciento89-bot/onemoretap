"""Independent exact archive and legacy profile checks for owned synthetic records."""
import json,math,xml.etree.ElementTree as ET
def profile(data:bytes):
 root=ET.fromstring(data);assert root.tag=='map';out={}
 for e in root:
  assert e.tag in ['int','boolean','string'] and e.get('name')not in out
  out[e.get('name')]=(e.tag,e.text if e.tag=='string'else e.get('value'))
 return out
def archive(data:bytes,count:int):
 d=json.loads(data);assert set(d)=={'schemaVersion','progress'}and d['schemaVersion']==1
 p=d['progress'];assert set(p)=={'recent','bests'}and len(p['recent'])==count;assert set(p['bests'])=={'TIMING','PRECISION','DIRECTIONS'}
 ids=set()
 def valid(v):
  assert set(v)=={'id','drill','finishedAt','attempts'}and isinstance(v['id'],str)and len(v['id'])>10 and v['drill']in p['bests']and isinstance(v['finishedAt'],int)and v['finishedAt']>0
  assert len(v['attempts'])==12 and all(type(x)in[int,float]and math.isfinite(x)and-180<=x<=180 for x in v['attempts'])
 for v in p['recent']:valid(v);assert v['id']not in ids;ids.add(v['id'])
 for key,v in p['bests'].items():valid(v);assert v['drill']==key and v['id']in ids
 return d
