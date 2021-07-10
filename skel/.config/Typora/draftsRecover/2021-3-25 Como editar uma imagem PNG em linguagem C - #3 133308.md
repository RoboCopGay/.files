# Como editar uma imagem PNG em linguagem C - #3

---

Eae galera, sou eeu o tiririca, hoje eu vou finalizar nossa mini lib, além é claro de um algoritmozinho com vários filtros para deixar nossas imagens estilosas.

Bora começar, no ultimo capítulo vimos mais especificamento o campo `IHDR`, mas de forma geral deu pra ter uma ideia de como iremos interpretar os outro chunks da imagem também, dessa vez iremos focar no campo `IDAT`, e a primeira coisa que tem que saber é que ele é sequencial, o que significa que em uma PNG podem haver apenas 1 ou vários, e isso é vantajoso principalmente por que se a imagem é muito grande você não vai estourar a memória do nosso pc carroça.

Antes de mais nada baixe a [versão finalizada da parte 2](https://gist.github.com/plankiton/8195dbe53d129ed65acb1011bd42b460)