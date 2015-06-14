


window.onload = function() {

		var sampler=44100;
		var pixsize = 0.005;
		var fspix = sampler*pixsize;
		
		var wave4 = new RIFFWAVE();
		wave4.header.sampleRate = sampler;
		wave4.header.numChannels = 1;
		var audio4 = new Audio(wave4.dataURI);
		
		var fileInput = document.getElementById('fileInput');
		var fileDisplayArea = document.getElementById('fileDisplayArea');
		var textArea = document.getElementById('textArea');
		var c = document.getElementById("myCanvas");
		var ctx = c.getContext("2d");
		var img = null;
		var reader = null;
		var imageType = null;
		
		function play(audio) {

		if (!audio.paused) { // if playing stop and rewind
			audio.pause();
			audio.currentTime = 0;
		}
		audio.play();
		}

		


		
		fileInput.addEventListener('change', function(e) {
			var file = fileInput.files[0];
			imageType = /image.*/;

			if (file.type.match(imageType)) {
				reader = new FileReader();

				reader.onload = function(e) {
					fileDisplayArea.innerHTML = "";

					img = new Image();
					img.src = reader.result;
					
					fileDisplayArea.appendChild(img);
					
					
				}
				reader.readAsDataURL(file);	
			} 
			else {
				fileDisplayArea.innerHTML = "File not supported!";
			}
		});
		
		function play2() {

						c.width=img.width;
						c.height=img.height;
						ctx.drawImage(img, 0, 0);
					
						var imgData = ctx.getImageData(0, 0, img.height,img.height);
						
						var data = []; // yes, it's an array
										
						for (var k=0; k<sampler*5; k++) { // fills array with samples
							var t = k/sampler;            // time from 0 to 1
							// Generate samples using sine wave equation (between 0 and 255)
							data[k] = 128+Math.round(127*Math.sin(3000*2*Math.PI*t));
						}
					
						var i = 0;

					
						for (i = 0; i < imgData.data.length; i += 4) {
							var pix = Math.round(0.2989*imgData.data[i]+ 0.5870*imgData.data[i+1]+0.1140*imgData.data[i+2]);
							imgData.data[i] = pix;
							imgData.data[i+1] = pix;
							imgData.data[i+2] = pix;
							imgData.data[i+3] = 255;
							freq=0;
							if (pix<31){
								freq=6000;
							}
							else if (pix<63){
								freq=7000;
							}
							else if (pix<93){
								freq=8000;
							}
							else if (pix<125){
								freq=9000;
							}
							else if (pix<157){
								freq=10000;
							}
							else if (pix<189){
								freq=11000;
							}	
							else if (pix<221){
								freq=12000;
							}		
							else if (pix<256){
								freq=13000;
							}
							for (var j=0; j<fspix; j++) { // fills array with samples
								var t = j/sampler;            // time from 0 to 1
								// Generate samples using sine wave equation (between 0 and 255)
								data[Math.round(sampler*5+(i/4)*fspix+j)] = 128+Math.round(127*Math.sin(freq*2*Math.PI*t));
							}
						}
					
					
						wave4.Make(data); // make the wave fil
						audio4.src = wave4.dataURI; // set audio source
						play(audio4); // we should hear two tones one on each speaker
						//your code to be executed after 1 seconds
		}
}

