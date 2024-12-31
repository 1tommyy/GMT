$(() => {

    var MusicVideoIndex = 0;
    var MusicVideos = [
        {
            MusicAuthor: 'Fredo',
            MusicLabel: 'Top G',
            MP4Location: 'https://cdn.discordapp.com/attachments/1233103296609259602/1238800965965189191/Fredo_-_Top_G_Official_Video.mp4?ex=66409ace&is=663f494e&hm=7fe28922d0839c5ea1e0c183788a0b70b12271020fd7d219131ed8eda376ba51&',
            IconLocation: 'https://cdn.discordapp.com/attachments/1200853764018544700/1202014520118091887/download.jpg?ex=65e799c1&is=65d524c1&hm=1217f4207ec797b50fb7c7175feb6c986b71e8aa6a1b48b3a0b67ec9f17c2a4a&'
        }
    ];

    var RandomizeArray = (array) => {

        let currentIndex = array.length, randomIndex;
    
        while (currentIndex != 0) {
    
            randomIndex = Math.floor(Math.random() * currentIndex);
            currentIndex--;
    
            [array[currentIndex], array[randomIndex]] = [
                array[randomIndex],
                array[currentIndex]
            ];
            
        };
    
        return array;

    }

    var Slider = document.getElementById('loading_bar');

    Slider.addEventListener('input', (event) => {
        
        let Video = document.getElementById('video');

        Video.currentTime = event.target.value;

    });

    var PlayVideo = (VideoIndex) => {

        var VideoData = MusicVideos[VideoIndex - 1];
        
        $('#loading_toggle').html(`<i class="fa-solid fa-pause"></i>`);

        document.getElementById('loading_video').innerHTML = `

            <video src="${VideoData.MP4Location}" id="video"></video>
                
        `;

        document.getElementById('loading_image').src = VideoData.IconLocation;

        $('#loading_label').text(VideoData.MusicLabel);
        $('#loading_author').text(VideoData.MusicAuthor);

        let Video = document.getElementById('video');

        Video.volume = 0.375;
        Video.play();

        Video.addEventListener('loadedmetadata', function() {

            $('#loading_total').text(new Date(Video.duration * 1000).toISOString().substring(15, 19));
            $('#loading_bar').attr('max', Video.duration);

        });

        Video.addEventListener('timeupdate', () => {
            
            $('#loading_current').text(new Date(Video.currentTime * 1000).toISOString().substring(15, 19));

            if (Video.duration != null && Video.currentTime != null) {

                document.getElementById('loading_bar').value = Video.currentTime;

            };
        
        });

    };

    Back = () => {

        MusicVideoIndex -= 1;

        if (MusicVideoIndex <= 0) {
    
            MusicVideoIndex = MusicVideos.length;

        };

        PlayVideo(MusicVideoIndex);

    };

    Toggle = () => {

        let Video = document.getElementById('video');

        if ($('#video').get(0).paused) {

            Video.play();

            $('#loading_toggle').html(`<i class="fa-solid fa-pause"></i>`);

        } else {

            Video.pause();
            
            $('#loading_toggle').html(`<i class="fa-solid fa-play"></i>`);

        };

    };

    Forward = () => {

        MusicVideoIndex += 1;

        if (MusicVideoIndex > MusicVideos.length) {
    
            MusicVideoIndex = 1;

        };

        PlayVideo(MusicVideoIndex);

    };

    MusicVideos = RandomizeArray(MusicVideos);

    MusicVideoIndex = 1;

    PlayVideo(MusicVideoIndex);

});
window.addEventListener("DOMContentLoaded", () => {
    if (window.nuiHandoverData.rageloading == "discord") {
      let _0x1fc1c2 = JSON.parse(window.nuiHandoverData.json).response.players[0];
      let _0x3ad761 = ["discordname", "user_id",    "online"];
      let _0x1b3e58 = 0;
      function _0x34d0ed() {
        let _0x48d2a2 = _0x3ad761[_0x1b3e58];
        $(".loading_info")
          .fadeOut(500, function () {
            $(this).html(_0x1fc1c2[_0x48d2a2]).fadeIn(500);
          });
        $(".loading_accountinfo_img").attr("src", _0x1fc1c2.discordpfp);
      }
  
      _0x34d0ed();
      setInterval(() => {
        _0x1b3e58 = (_0x1b3e58 + 1) % _0x3ad761.length;
        _0x34d0ed();
      }, 2000);
    }
  });
  
  