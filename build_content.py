"""Original authored, compact adaptation of The Sunlit Atlas GDD v2."""
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
rooms={}
def room(id,name,theme,description):
 rooms[id]={'name':name,'theme':theme,'description':description,'objects':[],'exits':[],'hazards':[]}
def obj(r,id,name,x,y,kind='evidence',**kw):
 rooms[r]['objects'].append(dict(id=id,name=name,x=x,y=y,kind=kind,**kw))
def link(a,b,ax,ay,bx,by,need=[]):
 rooms[a]['exits'].append(dict(to=b,x=ax,y=ay,spawn=[bx,by+24],need=need))
 rooms[b]['exits'].append(dict(to=a,x=bx,y=by,spawn=[ax,ay+24],need=[]))
for args in [
 ('town','Brightwater · Festival Square','town','Two processions. Two routes. One celebration at a standstill.'),
 ('cartography','Vale Cartography','interior','Mira keeps the sources close, and her conclusions in pencil.'),
 ('hall','Finch Hall & Civic Archive','interior','A public record can preserve a mistake as carefully as a truth.'),
 ('forest','Sunleaf · Twin Oaks','forest','Fresh paint shines on an old trail. The bark remembers another line.'),
 ('lodge','Ranger Lodge','interior','Orin has been listening to this forest longer than most maps have existed.'),
 ('river','Silverrun · Reedbank','river','Water changed the road. It did not erase the reasons.'),
 ('sluice','Sluice House','ruins','Three channels share one river: the mill, the ferry, and the nesting reeds.'),
 ('ruins','Mosaic Terrace','ruins','Some tiles are older than the story they now tell.'),
 ('copies','Hall of Copies','ruins','Every map faces its source. One repeated flaw travels through them all.'),
 ('coast','Beacon Point','coast','Beyond the warehouses, the public shore still waits.'),
 ('lighthouse','Beacon Lighthouse','interior','Light reaches where a shouted warning cannot.'),
 ('store','Tidal Storehouse','interior','A service passage opens at low tide. The missing record lies beyond.'),
 ('bell','Bell Isle','island','Three bells carry a message across the water.'),
 ('gull','Gullstone','island','A white cliff holds one third of the Coastkeeper seal.'),
 ('lantern','Lantern Key','island','A sheltered harbor and an old promise of public passage.'),
 ('orchard','Orchard Rock','island','Grafted trees bear the patient work of earlier travelers.'),
 ('far','Far Beacon','island','At the edge of the charts, a light still answers.'),
 ('under','The Underpath','under','Forgotten maintenance passages connect the route stations.'),
 ('mountain','Sunspire · Wind Gardens','mountain','A truthful route must also carry people safely.'),
 ('summit','Sunspire Summit','mountain','The whole valley lies below. Now make the case for its future.')]:room(*args)
link('town','cartography',480,154,480,420)
link('town','hall',220,176,480,420)
link('town','forest',895,270,70,270,['opening','paper1'])
link('town','river',480,480,90,280,['opening','paper1'])
link('town','mountain',740,95,90,280,['route'])
link('forest','lodge',230,150,480,420)
link('forest','river',850,410,90,120)
link('forest','ruins',850,150,90,270,['forest','river'])
link('river','sluice',250,145,480,420)
link('river','ruins',880,270,90,410,['sluice','forest','river'])
link('ruins','copies',480,145,480,420,['lens'])
link('ruins','coast',880,270,90,270,['copies','guardian','paper4'])
link('coast','lighthouse',480,220,480,420)
link('coast','store',700,390,480,420,['beacon'])
link('coast','bell',865,230,90,270,['beacon'])
link('bell','gull',860,200,90,260,['bell_seal'])
link('gull','lantern',860,280,90,260,['gull_seal'])
link('lantern','orchard',740,160,90,260)
link('orchard','far',900,300,90,270,['echoes'])
link('forest','under',640,410,140,400,['lens','line'])
link('under','coast',830,270,200,420,['underpath'])
link('mountain','summit',840,160,90,300,['mantle','rescue'])
evidence={}
def ev(r,id,title,x,y,text,source,date,limit,need=[]):
 evidence[id]=dict(title=title,text=text,source=source,date=date,location=rooms[r]['name'],limitation=limit)
 obj(r,id,title,x,y,text=text,need=need)
ev('town','banner','Festival banner',350,225,'A rising sun and two stitched oaks flank the eastern gate. The cloth is dated 1907.','Festival guild textile','1907','A ceremonial image suggests landmarks, but is not a survey.')
ev('cartography','atlas','The annotated atlas',480,240,'Northern road. Margin: Route updated from temporary survey copy. The map was published in 1912.','Town cartographers','1912','The map is official, but its source was temporary.')
ev('town','foundation','Monument foundation',580,330,'The old socket points east. Fresh tool scratches curve around the newer north-facing arrow.','Stone foundation','Undated','Wear establishes alteration, not the date or motive.')
ev('forest','stones','Eastern boundary stones',430,210,'Three worn sun symbols line up between Brightwater and the twin oaks. Their cuts sit beneath recent paint.','Survey marks in stone','Undated','The stones support an alignment, not its present safety.')
ev('lodge','song','Procession song',480,235,'Through the twin crowns, toward the dawn; past the river, to the public shore. The verse is preserved on an old shelter board.','Carved song, anonymous','Undated','Songs can change in transmission; compare the land.')
ev('forest','notches','Twin oak notches',700,235,'Beneath the paint, paired old cuts face the eastern boundary stones. The trees and song preserve the same line.','Living bark marks','Undated','Tree marks do not explain why the road was abandoned.', ['staff'])
ev('river','log','Ferryman’s log',440,180,'1908: The river rose beyond the chapel mark. The stone ford broke. Travelers were sent north until repairs could make a crossing safe.','Working ferryman','1908','A firsthand record of the flood, not the later mapmaking.')
ev('river','receipt','Northern bridge receipt',700,340,'Emergency northern access: timber and labor purchased after the 1908 flood.','Public works receipt','1908','A payment establishes work, not permanent route status.')
ev('river','survey','Broken ford survey',570,280,'The ford stones remain undermined. Even at low water, a crowded procession would be unsafe.','Current field inspection','Present','Conditions may change; this inspection applies now.')
ev('copies','tablet','Replacement tablet',350,230,'New glaze surrounds the northern detour. A chipped double notch occurs in both this 1909 replacement and the later atlas.','Restoration tablet','1909','Durable material does not make a copied route original.')
ev('copies','ledger','Repair ledger',610,230,'1909: Transfer the temporary survey line to the replacement tablet pending review. One later page has been torn out.','Restoration workers','1909','The missing page limits what this volume can prove.')
ev('ruins','tracing','Atlas tracing sheet',700,310,'A tracing overlays the tablet’s northern line and reproduces its double notch. It bears the atlas workshop seal.','Map workshop tracing','1912','This connects copying, but does not identify a later motive.', ['lens'])
ev('store','handbill','Merchant handbill',350,200,'1913: The OFFICIAL festival road ends at the northern warehouses. Supplies, storage, and lodging available.','Merchant consortium','1913','Advertising reveals an interest; it does not alone prove manipulation.')
ev('store','missing','The missing ledger page',610,210,'The consortium asks clerks to retain the warehouse destination and omit temporary from the route description. The torn edge matches the repair ledger.','Consortium letter attached to ledger','1913','It proves this request, not that every civic worker agreed.')
ev('store','accounts','Warehouse account book',480,320,'Festival storage and lodging income rose after travelers were directed to the warehouses.','Warehouse accounts','1913–1916','Income supports benefit, but benefit alone does not prove intent.')
ev('hall','signs','Sign painter’s receipt',350,230,'Remove temporary from the northern road signs; repaint the destination as warehouse road.','Civic sign painter','1914','Records an instruction; does not explain every resident’s belief.', ['coast'])
ev('hall','programs','Festival programs',620,220,'1908: emergency detour. 1912: northern route. 1916: traditional northern road. Repetition slowly replaced qualification.','Festival committee','1908–1916','Programs show public language, not private motives.', ['coast'])
ev('hall','charter','Varn maintenance charter',480,315,'The Varn family inherited upkeep of the northern road after its adoption. The charter does not establish involvement in the 1908 decision.','Civic charter','Later civic period','Inherited responsibility is not proof of originating the deception.', ['coast'])
# Awarded sources remain full journal entries.
for id,title,text,source,limit in [
 ('accord','Coastkeeper Accord','The three island fragments share a seal: Beacon Point is held for public access.','Coastkeepers, historic accord','Public rights still require a safe physical access route.'),
 ('ferrytest','Modern ferry safety test','A restored drive, balanced cargo, and protected reed channel passed a supervised crossing.','Tavi and Liora, present inspection','The crossing needs ongoing maintenance and weather checks.'),
 ('habitat','Habitat survey','The old forest line can reopen if traffic stays on marked ground and nesting reeds retain flow.','Orin and Liora, present survey','Seasonal changes will require later review.'),
 ('access','Public access inspection','A marked coastal walkway reaches the lawful shore above the sensitive tide pools.','Inez and Liora, present inspection','Access must close during dangerous storms.')]:evidence[id]=dict(title=title,text=text,source=source,date='See source',location='Regional investigation',limitation=limit)
mentors=[('cartography','mira','Mira Vale',395,270,'purple','The two processions each carry a piece of the story. Read the atlas margin, then compare the banner and the monument. An official map can faithfully copy a temporary source.'),('town','aster','Aster Finch',450,300,'blue','I stopped rehearsal before either group got hurt. We need a route people can trust. Visit Mira inside the coral-roofed cartography house.'),('lodge','orin','Orin Moss',390,280,'green','Recent paint is easy to see; old cuts take patience. The lodge song, boundary stones, and bark should be compared. Take this Wayfinder staff. Use Space to clear loose branches and gently turn away creatures.'),('river','tavi','Tavi Reed',320,300,'red','That ford is still broken. Read the log and receipt before judging the detour. In the sluice house, leave one channel for the reeds and two for the ferry. Take my river line.'),('ruins','sela','Sela Marr',370,275,'purple','This lens shows repairs beneath the glaze. In the Hall of Copies, turn each map toward its source: first survey, then tablet, then atlas. Leave unsupported parts blank.'),('coast','inez','Inez Sol',350,300,'red','The lighthouse can show you the islands. The lens carriage remembers a short, long, short signal. Take a signal lantern. Public access is a promise we must keep safely.'),('town','varn','Councilor Varn',670,280,'blue','I maintain the northern road. If you want a change, show how you will carry a crowd across that broken ford. The oldest route is not automatically the safest.')]
for r,id,name,x,y,sprite,text in mentors:obj(r,id,name,x,y,'npc',sprite=sprite,text=text,gift={'orin':'staff','tavi':'line','sela':'lens','inez':'lantern'}.get(id,''))
puzzles={}
def puzzle(r,id,name,x,y,text,labels,choices,answer,need=[],reward=[],paper=0,award=[]):
 puzzles[id]=dict(name=name,text=text,labels=labels,choices=choices,answer=answer,need=need,reward=reward,paper=paper,award=award)
 obj(r,id,name,x,y,'puzzle',need=need)
puzzle('town','opening','Turn the plaza arrow',580,355,'The foundation socket is older than the rotated arrow. Align the arrow with the old socket; compare the two procession sources first.',['Arrow'],[['North','East','South','West']],[1],['atlas','banner','foundation'],paper=1)
puzzle('forest','forest','Align the boundary markers',540,300,'Orin’s shelter verse names the route in order: twin crowns, river, public shore. Rotate the three markers to carry that sequence through the grove.',['Near stone','Middle stone','Far stone'],[['Shore','Twin oaks','River']]*3,[1,2,0],['stones','song','notches','staff'],paper=2)
puzzle('sluice','sluice','Balance the sluice',480,250,'The brass plate reads: four units total. One for the mill, two for the ferry, one for nesting reeds. Closing the reeds would drain a habitat. Set each gate.',['Mill','Ferry','Reeds'],[['0','1','2','3']]*3,[1,2,1],['line'])
puzzle('river','river','Rebuild the flood sequence',300,375,'Fit the events into Tavi’s timeline rack. Use the dated log and receipt: water rises, the ford breaks, then northern access opens.',['First','Then','Finally'],[['Northern detour','Rising water','Broken ford']]*3,[1,2,0],['log','receipt','survey','sluice'],paper=3)
puzzle('copies','copies','Turn the source gallery',480,300,'Turn each gallery frame toward the source it copied. The ledger names the temporary survey as the tablet’s source. The tracing carries the tablet’s flaw into the atlas.',['1909 tablet faces','1912 tracing faces','1912 atlas faces'],[['Temporary survey','Replacement tablet','Tracing sheet']]*3,[0,1,2],['tablet','ledger','tracing','lens'],paper=4)
puzzle('copies','guardian','Reset the route guardian',760,315,'The guardian pulses across the chamber. Its maintenance panel asks for the original route stations: oaks, river, shore. Rebuild its sequence to make the chamber safe.',['First station','Second station','Third station'],[['Shore','Oaks','River']]*3,[1,2,0],['copies','staff'])
puzzle('lighthouse','beacon','Restore the beacon signal',480,250,'Inez taught the harbor call: short, long, short. Set the three shutters. The charted island passages will open.',['Shutter I','Shutter II','Shutter III'],[['Dark','Short','Long']]*3,[1,2,1],['lantern'])
for r,id,title in [('bell','bell_seal','Bell Isle seal'),('gull','gull_seal','Gullstone seal'),('lantern','lantern_seal','Lantern Key seal')]:obj(r,id,title,530,250,'collect',text='A fragment of the Coastkeeper seal. It records a shared duty to keep Beacon Point open to the public.')
puzzle('coast','coast','Assemble the public shore case',570,345,'Inez’s case table has places for ownership, action, and benefit. Fit the records according to what each can actually show.',['Public right','Pressure on clerks','Financial benefit'],[['Coastkeeper Accord','Missing ledger page','Account book']]*3,[0,1,2],['bell_seal','gull_seal','lantern_seal','handbill','missing','accounts'],paper=5,award=['accord'])
puzzle('hall','civic','Ring the civic timeline',740,320,'Ring the four dated plates in sequence. The records trace change through emergency, copying, promotion, then removal of qualifying language. Varn inherited road maintenance; these records do not make him the original author.',['1908','1909','1913','1914'],[['Flood detour','Copied tablet','Merchant handbill','Repainted signs']]*4,[0,1,2,3],['coast','signs','programs','charter'])
puzzle('river','ferry','Test the public ferry',800,375,'A safe crossing needs a balanced deck, a secured river line, and steady flow. Tavi’s test plate: passengers left, counterweight right, river line secured.',['Left deck','Right deck','River line'],[['Empty','Passengers','Counterweight'],['Passengers','Empty','Counterweight'],['Loose','Secured']],[1,2,1],['civic','sluice','line'],award=['ferrytest'])
puzzle('forest','habitat_route','Protect the grove route',750,355,'Orin points out nesting ground beside the old marks. Keep people on the marked trail, maintain a rope edge, and leave nests undisturbed.',['Trail','Boundary','Nests'],[['Marked ground','New shortcut'],['Rope edge','Remove markers'],['Leave undisturbed','Move nests']],[0,0,0],['civic','staff'],award=['habitat'])
puzzle('ruins','markers','Authenticate the route markers',560,355,'Sela’s lens separates old edges from guesswork. Restore the supported east alignment; keep the missing section visibly blank.',['Route alignment','Missing tile'],[['North','East'],['Invent a match','Leave blank']],[1,1],['civic','lens'])
puzzle('coast','access_route','Open the shore walkway',730,310,'Inez proposes an elevated marked walkway. It protects the pools and keeps access public, with storm closures.',['Path','Access','Storms'],[['Across tide pools','Raised walkway'],['Public','Private toll'],['Close when unsafe','Always open']],[1,0,0],['civic','lantern'],award=['access'])
puzzle('town','route','Build the living route',740,350,'Mira’s route board must honor the evidence and today’s conditions. The ford is unsafe. Keep the eastern line, use the tested ferry, pass the authenticated ruins, and reach public shore.',['Forest','Crossing','Destination'],[['Eastern marks','Northern warehouses'],['Broken ford','Public ferry'],['Public shore','Private stores']],[0,1,0],['ferry','habitat_route','markers','access_route','paper5'])
obj('mountain','mantle','Wayfinder storm shelter',330,245,'collect',text='A wind mantle rests beside the shelter record. Hold Shift to steady your pace; the mantle protects against wind. Marked circles warn of falling stone.')
obj('mountain','rescue','Help the stranded council',720,330,'collect',need=['mantle'],text='You secure the river line across the damaged steps. The council members cross one at a time. The safe ascent is open.')
puzzle('summit','synthesis','Present the living route',600,265,'Varn asks: how does this proposal answer the ford? Present the tested ferry, distinguish benefit from proof of pressure, and acknowledge maintenance. The council needs a qualified case, not certainty without evidence.',['Ford response','Proof of pressure','Limitation'],[['Restore old ford','Tested public ferry'],['Income alone','Ledger request'],['No uncertainty','Ongoing maintenance']],[1,1,1],['route','rescue','accord','ferrytest','habitat','access','charter','paper1','paper2','paper3','paper4','paper5'],paper=6)
obj('summit','ending','Light the living line',730,325,'ending',need=['synthesis','paper6'],text='The council approves the living route. Varn accepts its safety plan. From Brightwater to the public shore, torches join into one bright line. Your compass rests, then pulses once toward the distant islands.')
puzzle('bell','echoes','Answer the island bells',700,330,'The carved bell score reads low, high, middle. Each bell also flashes its name so the pattern can be read without sound.',['First bell','Second bell','Third bell'],[['Low','Middle','High']]*3,[0,2,1],['lantern'])
puzzle('under','underpath','Wake the old conduits',480,250,'The maintenance diagram combines the river and beacon rules: reeds one, ferry two, lantern long. Carry those working settings into the old system.',['Reeds','Ferry','Lantern'],[['0','1','2'],['0','1','2'],['Dark','Short','Long']],[1,2,2],['line','lantern','lens'])
obj('orchard','orchard_story','Cira’s orchard journal',520,260,'collect',text='The eastern orchard survived because neighbors kept sharing grafts and water after the public route moved. A quiet act of memory. Your festival gains orchard lanterns.')
obj('far','far_story','The distant Wayfinder light',560,245,'collect',text='A brass note reads: No map is finished while people still travel. The old keepers left room for the next generation. Your compass answers.')
for r in rooms:
 obj(r,'rest_'+r,'Rest & refill vitality',220,360,'rest',text='You rest, refill your sun pips, and record your progress.')
 if rooms[r]['theme'] in ('forest','river','ruins','coast','mountain','under','island'):
  rooms[r]['hazards']=[{'x':620,'y':370,'radius':22,'type':'wind' if rooms[r]['theme']=='mountain' else 'creature'},{'x':430,'y':330,'radius':18,'type':'pulse' if rooms[r]['theme'] in ('ruins','under') else 'creature'}]
works=[
 'Before leaving Brightwater, predict which direction the historic Sunpath followed. Use one detail from the banner and one from the atlas or monument.',
 'Which two discoveries most strongly support the eastern forest route? Explain how they reinforce each other.',
 'Why did Brightwater change the route after 1908? Was the original decision reasonable? Support both parts.',
 'Explain how the temporary detour became part of the official atlas. Identify one source limitation.',
 'Who benefited from the northern route, and what evidence shows that benefit? Explain why motive alone does not prove the case.',
 'Recommend the modern festival route. Use at least four sources from three regions, address the broken ford, and explain one limitation or tradeoff.'
]
gemini_file=ROOT/'data/gemini_mira.json'
if gemini_file.exists():
 line=json.loads(gemini_file.read_text())['dialogue']
 for o in rooms['cartography']['objects']:
  if o['id']=='mira':o['text']=line+' '+o['text']
(ROOT/'data/world.json').write_text(json.dumps(dict(rooms=rooms,evidence=evidence,puzzles=puzzles,worksheets=works),ensure_ascii=False,indent=2))
print(f'{len(rooms)} sectors, {len(evidence)} sources, {len(puzzles)} mechanisms')
