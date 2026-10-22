"""Original NavoTap instrumental: eight bars,84BPM,D-minor pads/plucks; no external samples."""
from pathlib import Path
from array import array
import math,wave,json,hashlib
RATE=22050;BEAT=60/84;DURATION=32*BEAT;N=round(RATE*DURATION)
audio=[0.0]*N
notes=[(50,57,62),(46,53,58),(48,55,60),(45,52,57)]
def note(midi,start,length,gain,pluck=False):
    frequency=440*2**((midi-69)/12);count=round(length*RATE)
    for j in range(count):
        t=j/RATE;attack=min(1,t/(0.012 if pluck else 0.35));release=min(1,(length-t)/(0.15 if pluck else 0.7))
        envelope=max(0,attack*release)*(math.exp(-3*t) if pluck else 1)
        timbre=math.sin(math.tau*frequency*t)+0.16*math.sin(math.tau*frequency*2*t)
        audio[(round(start*RATE)+j)%N]+=gain*envelope*timbre
for bar in range(8):
    chord=notes[bar//2]
    for pitch in chord: note(pitch,bar*4*BEAT,4*BEAT,0.035)
    for step in range(8):note(chord[step%3]+12,(bar*4+step/2)*BEAT,BEAT*0.8,0.055,True)
    note(chord[0]-12,bar*4*BEAT,BEAT*1.9,0.06)
# Circular echo preserves the loop boundary, avoiding a cut-off reverb tail.
for delay,gain in [(round(BEAT*0.75*RATE),0.16),(round(BEAT*1.5*RATE),0.07)]:
    original=audio.copy()
    audio=[value+gain*original[(i-delay)%N] for i,value in enumerate(audio)]
# Short symmetrical fade makes endpoints exactly silent and avoids a restart click.
fade=round(0.014*RATE)
for i in range(fade):
    factor=math.sin(math.pi*0.5*i/fade)**2;audio[i]*=factor;audio[-i-1]*=factor
pcm=array('h',(round(max(-0.9,min(0.9,x))*32767) for x in audio))
p=Path(__file__).resolve().parents[1]/'android/app/src/main/res/raw/pulse_garden.wav'
with wave.open(str(p),'wb') as out:out.setnchannels(1);out.setsampwidth(2);out.setframerate(RATE);out.writeframes(pcm.tobytes())
peak=max(abs(x)for x in pcm)/32768;rms=math.sqrt(sum((x/32768)**2 for x in pcm)/len(pcm))
assert 0.01<rms<0.3 and peak<0.9 and pcm[0]==pcm[-1]==0
(Path(__file__).resolve().parent/'music/pulse_garden.provenance.json').write_text(json.dumps({'title':'Pulse Garden','author':'Kamilunavo original procedural composition','externalSamples':False,'bpm':84,'bars':8,'seconds':N/RATE,'sampleRate':RATE,'channels':1,'peak':peak,'rms':rms,'seamDelta':abs(pcm[0]-pcm[-1]),'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'humanListeningVerified':False},indent=2)+'\n')
print('Original loop generated and PCM bounds verified')
