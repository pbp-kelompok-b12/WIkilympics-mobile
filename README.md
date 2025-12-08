# WIkilympics Mobile

## Anggota Kelompok
- Muhammad Iffan Chalif Aziz – 2406435250
- Naira Ammara Putri – 2406433112
- Qoriana Syahwa Maharani – 2406437533
- Razan Muhammad Salim – 2406496233
- Saffana Firsta Aqila – 2406440023
- Vanessa – 2406426220

## Deskripsi Aplikasi
WIkilympics merupakan sebuah aplikasi mobile yang dirancang untuk menyediakan informasi lengkap mengenai olahraga Olimpiade. Aplikasi ini memuat beragam data terkait cabang olahraga, profil atlet, berita terbaru, serta informasi mengenai event yang akan berlangsung. Selain sebagai sumber pengetahuan, WIkilympics juga menawarkan fitur interaksi berupa forum dan ulasan, sehingga pengguna dapat berdiskusi, berbagi pandangan, serta mengikuti perkembangan dunia Olimpiade dengan lebih mendalam. Dengan antarmuka yang informatif dan interaktif, WIkilympics menjadi sarana tepercaya bagi pengguna yang ingin memahami dunia Olimpiade secara komprehensif.

## Daftar Modul
- **Sports 🏅** (Saffana Firsta Aqila)

    Modul Sports menampilkan *list of sports* yang dipertandingkan dalam Olimpiade. Pada halaman utama modul ini, pengguna dapat melihat seluruh cabang olahraga dalam daftar kartu yang rapi. Setiap kartu olahraga dapat diklik untuk membuka halaman detail olahraga. Pengguna juga dapat mencari suatu olahraga melalui search bar dan filter kategori. 

    Di halaman detail, pengguna dapat menemukan informasi jenis partisipasi (individu, team, or both), jenis disiplin (athletic, strength, etc), sejarah, hingga peralatan yang digunakan. Modul ini dirancang agar pengguna dapat mempelajari karakteristik setiap olahraga secara mendalam.

    Admin dapat menambahkan, mengedit, dan menghapus suatu olahraga.

- **Athletes 🏃‍♂️** (Muhammad Iffan Chalif Aziz)

    Modul Athletes menampilkan *list of athletes* yang berpartisipasi dalam Olimpiade. Pada halaman utama modul ini, pengguna dapat melihat deretan atlet dalam bentuk kartu yang berisi nama, foto, negara asal, dan disiplin olahraga yang mereka geluti. Pengguna juga dapat mencari seorang atlet melalui search bar dan filter kategori.

    Ketika pengguna mengklik salah satu kartu, mereka akan diarahkan ke halaman detail atlet. Di halaman detail, pengguna dapat membaca biografi atlet tersebut. Modul ini membantu pengguna untuk mengenal lebih dekat para atlet dari berbagai negara dan disiplin olahraga.

    Admin dapat menambahkan, mengedit, dan menghapus suatu profil atlet.

- **Upcoming Events 📅** (Naira Ammara Putri)

    Modul Upcoming Events berfungsi sebagai pusat informasi jadwal event Olimpiade yang akan datang. Setiap event ditampilkan dengan detail seperti nama penyelenggara, lokasi pelaksanaan, tanggal pelaksanaan, serta cabang olahraga yang dipertandingkan. Pengguna dapat mencari suatu event melalui search bar dan mengklik salah satu kartu untuk membaca detail event.

    Admin dapat menambahkan, mengedit, dan menghapus suatu event.
    
- **News & Articles 📰** (Vanessa)
    
    Modul News & Articles menampilkan *list of news/articles* terkini seputar olahraga Olimpiade. Pada halaman utama modul ini, pengguna dapat melihat daftar berita dalam bentuk kartu yang menampilkan judul, kategori olahraga, dan tanggal publikasi. Pengguna juga dapat mencari suatu berita melalui filter kategori olahraga. Halaman ini juga dilengkapi fitur voting (upvote dan downvote) sehingga pengguna dapat memberikan penilaian terhadap kualitas dan relevansi berita tersebut.

    Saat pengguna memilih salah satu berita, mereka diarahkan ke halaman detail berita untuk membaca isi berita secara lengkap. Pengguna juga dapat bernavigasi ke halaman detail olahraga terkait dan bernavigasi ke forum diskusi.

    Admin dapat menambahkan, mengedit, dan menghapus suatu berita.

- **Forum & Review Pages 💬** (Razan Muhammad Salim) 

    Modul Forum and Review Pages berfungsi sebagai ruang interaksi antar pengguna yang terautentikasi untuk berbagi pendapat dan pengalaman seputar olahraga olimpiade. Pengguna dapat memberikan (menambahkan), mengedit, dan menghapus ulasannya sendiri. Pengguna juga dapat berinteraksi dengan pengguna lain dalam forum menggunakan fitur reply.

    Admin dapat menghapus ulasan pengguna manapun yang dianggap tidak sesuai atau melanggar ketentuan, sehingga atmosfer forum tetap positif dan informatif.

- **Landing Page & Polls 📊** (Qoriana Syahwa Maharani)

    Landing Page merupakan tampilan utama pertama yang dilihat pengguna. Modul ini menyajikan informasi singkat mengenai aplikasi WIkilympics, termasuk integrasi seluruh modul. Pengguna dapat bernavigasi ke seluruh detail modul melalui halaman ini. Modul ini juga dilengkapi fitur polling yang bertujuan untuk meningkatkan interaktivitas pengguna. Pengguna dapat memberikan suara hanya dengan satu klik saat pertama kali mengakses halaman Landing Page, dan hasil polling akan diperbarui secara dinamis sesuai jumlah vote yang masuk.

    Admin dapat menambahkan, mengedit, dan menghapus pertanyaan polling terkait olahraga Olimpiade.

## Peran Pengguna Aplikasi
- Pengguna (User)
    - Menjelajahi informasi seputar olahraga, atlet, berita, dan event Olimpiade melalui halaman list, pencarian, dan detail.
    - *[Khusus pengguna terautentikasi]* Memberikan ulasan serta berinteraksi dalam forum komunitas melalui fitur *reply*.
- Admin
    - Mengelola seluruh informasi dalam aplikasi—mulai dari olahraga, atlet, berita, event, hingga forum diskusi—dengan menambahkan, mengedit, dan menghapus data agar tetap akurat dan terbarui.

## Alur pengintegrasian dengan *web service* untuk terhubung dengan aplikasi web yang sudah dibuat saat Proyek Tengah Semester

Integrasi dimulai dengan **menambahkan dependensi `http` pada proyek Flutter**. Dependensi ini memungkinkan Flutter melakukan http request ke web service Django.

Setelah itu, **dibuat model sesuai dengan respons dari data yang berasal dari web service tersebut**. Model ini memerlukan method `fromJson` dan `toJson` agar data dari Django dapat dikonversi dengan mudah ke objek Dart dan sebaliknya.

Kemudian **dilakukan http request ke web service menggunakan dependensi `http`**. Objek yang diterima dari web service kemudian **dikonversi ke model yang telah dibuat sebelumnya** menggunakan `Model.fromJson()`.

Tahap akhir adalah **menampilkan data yang sudah dikonversi melalui widget seperti `FutureBuilder`**. Widget ini memastikan antarmuka menyesuaikan keadaan data, seperti menampilkan indikator loading saat permintaan sedang diproses, menampilkan error bila terjadi kegagalan, atau menyajikan daftar dan halaman detail ketika data berhasil diambil.

[Link Figma](https://www.figma.com/design/8s9shJvl1GytVinYODj2Mw/Untitled?node-id=2-11&t=RTs0siFokXQJyazt-1)
Untuk Design terdapat pada page 2



