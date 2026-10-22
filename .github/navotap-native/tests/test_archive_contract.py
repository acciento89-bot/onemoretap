import importlib.util,pathlib,json,unittest
s=importlib.util.spec_from_file_location('c',pathlib.Path(__file__).resolve().parents[1]/'archive_contract.py');m=importlib.util.module_from_spec(s);s.loader.exec_module(m)
class ArchiveContract(unittest.TestCase):
 def data(self):
  rows=[{'id':'own-completed-'+d,'drill':d,'finishedAt':1792656000000,'attempts':[0]*12}for d in ['TIMING','PRECISION','DIRECTIONS']]
  return{'schemaVersion':1,'progress':{'recent':rows,'bests':{r['drill']:r for r in rows}}}
 def test_all_three_actual_completed_drills_required(self):
  m.archive(json.dumps(self.data()).encode(),3)
  for change in ['future','partial','duplicate','nan']:
   d=self.data()
   if change=='future':d['schemaVersion']=2
   elif change=='partial':d['progress']['recent'][0]['attempts'].pop()
   elif change=='duplicate':d['progress']['recent'][1]['id']=d['progress']['recent'][0]['id']
   else:d['progress']['recent'][0]['attempts'][0]=float('nan')
   with self.assertRaises(AssertionError):m.archive(json.dumps(d).encode(),3)
 def test_profile_values_compared_without_xml_order_dependency(self):
  a=b'<map><int name="wallet.coins" value="23"/><int name="classic.bestScore" value="17"/></map>';b=b'<map><int name="classic.bestScore" value="17"/><int name="wallet.coins" value="23"/></map>';self.assertEqual(m.profile(a),m.profile(b));self.assertNotEqual(m.profile(a),m.profile(b.replace(b'23',b'24')))
