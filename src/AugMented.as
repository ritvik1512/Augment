package
{
	import com.transmote.flar.FLARManager;
	import com.transmote.flar.camera.FLARCamera_PV3D;
	import com.transmote.flar.marker.FLARMarker;
	import com.transmote.flar.marker.FLARMarkerEvent;
	import com.transmote.flar.tracker.FLARToolkitManager;
	import com.transmote.flar.utils.geom.FLARGeomUtils;
	import com.transmote.flar.utils.geom.PVGeomUtils;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.media.Video;
	
	import org.papervision3d.materials.MovieMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.render.LazyRenderEngine;
	import org.papervision3d.scenes.Scene3D;
	import org.papervision3d.view.Viewport3D;
	
	[SWF(width='640', height='480', backgroundColor='#000000', frameRate='40')]
	
	public class AugMented extends Sprite
	{
		private var fm:FLARManager;
		private var scene:Scene3D;
		private var view:Viewport3D;
		private var camera:FLARCamera_PV3D;
		private var lre:LazyRenderEngine;
		private var p:Plane;
		private var marker:FLARMarker;
		private var v:Vid;
		private var con:DisplayObject3D;
		
		public function AugMented()
		{
			initFLAR();
			v = new Vid();
			v.vid.source = "asjs3.mov";
			v.vid.stop();
		}
		
		private function initFLAR():void
		{
			fm = new FLARManager("flarConfig.xml", new FLARToolkitManager, this.stage);
			fm.addEventListener(FLARMarkerEvent.MARKER_ADDED, onAdded);
			fm.addEventListener(FLARMarkerEvent.MARKER_REMOVED, onRemoved);
			fm.addEventListener(Event.INIT, init3D);
			addChild(Sprite(fm.flarSource));
		}
		
		private function onAdded(e:FLARMarkerEvent):void
		{
			marker = e.marker;
			p.visible = true;
			v.vid.play();
		}
		
		private function onRemoved(e:FLARMarkerEvent):void
		{
			marker = null;
			p.visible = false;
			v.vid.stop();
		}
		
		private function init3D(e:Event):void
		{
			scene = new Scene3D();
			camera = new FLARCamera_PV3D(this.fm, new Rectangle(0, 0, this.stage.stageWidth, this.stage.stageHeight));
			camera.z = -30;
			view = new Viewport3D(640, 480, true);
			lre = new LazyRenderEngine(scene, camera, view);
			
			var mat:MovieMaterial = new MovieMaterial(v, false, true);
			p = new Plane(mat, 320, 240, 2, 2);
			p.scaleY = -1;
			p.rotationZ = 90;
			p.visible = false;
			
			con = new DisplayObject3D();
			con.addChild(p);
			scene.addChild(con);
			addChild(view);
			
			addEventListener(Event.ENTER_FRAME, loop);
			
		}
		
		private function loop(e:Event):void
		{
			if(marker != null)
			{
				con.transform = PVGeomUtils.convertMatrixToPVMatrix(marker.transformMatrix);
			}
			lre.render();
		}
	}
}