from pathlib import Path
import json
from reportlab.pdfgen import canvas
from reportlab.lib.colors import HexColor
from reportlab.lib.utils import simpleSplit
R=Path(__file__).resolve().parents[1];b=json.loads((R/'data/world.json').read_text())
c=canvas.Canvas(str(R/'docs/Wayfinder-Worksheet.pdf'),pagesize=(612,792));c.setTitle('The Sunlit Atlas - Wayfinder Worksheet')
titles=['Initial prediction','Physical evidence','A temporary change','The copied error','Motive and public consequence','The living route']
for i,prompt in enumerate(b['worksheets']):
 c.setFillColor(HexColor('#123f45'));c.rect(0,696,612,96,fill=1,stroke=0)
 c.setFillColor(HexColor('#f2d27e'));c.setFont('Helvetica-Bold',12);c.drawString(42,759,'THE SUNLIT ATLAS / PATHS OF BRIGHTWATER')
 c.setFillColor(HexColor('#fff4d5'));c.setFont('Helvetica-Bold',23);c.drawString(42,721,f'{i+1}. {titles[i]}')
 c.setFillColor(HexColor('#294d48'));c.setFont('Helvetica',10);c.drawString(42,671,'Name: ____________________________    Date: __________________')
 y=628;c.setFont('Helvetica',13)
 for line in simpleSplit(prompt,'Helvetica',13,524):c.drawString(42,y,line);y-=20
 y-=22;c.setFont('Helvetica-Oblique',10)
 c.drawString(42,y,'Cite the source, explain your reasoning, and state what the evidence cannot establish.')
 y-=32;c.setStrokeColor(HexColor('#c3cdbd'));c.setLineWidth(.6)
 for yy in range(int(y),105,-26):c.line(42,yy,570,yy)
 c.setFillColor(HexColor('#496c62'));c.setFont('Helvetica',9)
 c.drawString(42,66,'Your answer stays on this paper. The game saves only your acknowledgement.')
 c.drawRightString(570,44,f'Checkpoint {i+1} of 6');c.showPage()
c.save()
lines=['# Walkthrough and mechanism reference','', 'Spoilers below. This is a facilitator/developer reference, not required reading to play.','', 'Follow the current-purpose banner. E operates every marked door and object. A compass pulse (C) names the nearest unfinished interaction. All six paper prompts must be acknowledged; use the journal while a prompt is open, then close it to return.','']
for id,p in b['puzzles'].items():
 room=next(r['name'] for r in b['rooms'].values() if any(o['id']==id for o in r['objects']))
 lines += ['## '+p['name'],'', 'Location: '+room,'',p['text'],'','Settings: '+ '; '.join(label+' = '+str(p['choices'][j][p['answer'][j]]) for j,label in enumerate(p['labels']))+'.','']
lines += ['## Required return route','', 'After the coast case, return to Finch Hall. Gather all three civic records and complete the civic timeline. Revisit Silverrun for the ferry test, Sunleaf for habitat protection, the ruins for markers, and the coast for the walkway. Assemble the route board in Brightwater, ascend the north road, collect the mantle, rescue the council, and present the summit case. Acknowledge worksheet six before lighting the living line.','', 'Optional hub travel is available in the map after sluice and beacon restoration. It travels only to previously visited locations.','']
(R/'docs/WALKTHROUGH.md').write_text('\n'.join(lines))
print('Built six-page printable worksheet and mechanism reference.')
