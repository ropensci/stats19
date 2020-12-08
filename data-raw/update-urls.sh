# aim: update urls using the sd utility, written in Rust

sd '' '' $(fd .)
sd 'http://www.roadpeace.org/take-action/crash-not-accident/' 'https://www.roadpeace.org/take-action/crash-not-accident/' $(fd .)
sd 'https://moderndive.netlify.com/1-getting-started.html' 'https://moderndive.netlify.app/1-getting-started.html' $(fd .)

