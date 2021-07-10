> *Como o código vai acabar um pouco complicando, então eu sugiro que você siga o post com* [*esse gist*](https://gist.github.com/plankiton/8195dbe53d129ed65acb1011bd42b460) *aberto para conseguir localizar onde fica cada código, então leia o código e tente encontrá-lo por la..*

Como foi visto no final do ultimo capítulo, sempre que exibimos as informações de tamanho do `chunk.data` ou até mesmo as dimensões da imagem (`header.height` e `header.width`) temos valores totalmente diferentes do que é esperado.

Neste post resolveremos este bug e eu direi algumas informações não explicadas sobre o cabeçalho do arquivo.

### Little endianess

![img](https://cdn-images-1.medium.com/max/800/0*TWKNKhW-2PDfhoe4.png)

Basicamente todo o bug que vimos ocorrer no capítulo anterior foi causado por causa de uma coisa chamada “Little endianess”, que não tem uma tradução correta para o português, mas que iremos chamar aqui no post (por puro capricho) de “friscura do processador”, brincadeira… Mas enfim, antes de explicar exatamente sobre oque estou falando, vou dar uma exemplificada para tornar as coisas mais fáceis para o meu lado.

> *Para uma explicação decente sobre o assunto entre* [*neste link*](https://gulliver.readthedocs.io/en/stable/What-is-Endianness.html)*.*

Aqui nós temos o iniciozinho da nossa imagem pequenininha em versão hexadecimal (é só usar um leitor de binário de sua preferência, eu estou em um linux então irei usar o `xxd`):

![img](https://cdn-images-1.medium.com/max/800/0*-v23jcErLqel8uBL.png)

> *Se nós fizermos a leitura do nosso chunk e ao invés de apenas armazenar e escrever cada byte na tela (com sua devida classificação) teríamos o seguinte código (substitua o código da função main) e output respectivamente:*

```
// Criando o arquivo e abrindo a imagem
FILE * image = fopen("image.png", "rb");
if (!image)
    die("Não foi possível ler a imagem");
if (!is_PNG(image))
    die("A imagem não é uma PNG");
                                                                                          
Chunk bloco;
fread(&bloco, 8, 1, image); // Criando buffer de dados com o tamanho lido
bloco.data = malloc(bloco.lenght); // Lendo o tipo e validando se o cabeçalho existe
bloco.type[4] = 0;
if (strcmp(bloco.type, "IHDR")) 
    die("Cabeçalho do arquivo está corrompido");
printf("Tamanho do cabecalho: %x\n", bloco.lenght);
return 0;

```

Saída:

```
Tamanho do cabecalho: d000000

```

Se você notar, os primeiros 8 valores da parte selecionada na imagem é `0000 000d` enquanto no programa ele retorna `d00 000` ou `0d00 0000`, já que o primeiro `0` é um zero a esquerda, então é desconsiderado.

Logo, é o mesmo valor só que invertido, isso é basicamente “little endian”, quando o C vai ler um valor e armazenar em uma variável ele inverte achando que está corrigindo o processo realizado pelo processador (já que é mais fácil ler da direita para a esquerda em baixo nível), e acaba dando esse bug, já que `0000000d` é igual a `13` enquanto `0d00 0000` é igual a `218103808`.

Logo, o que temos que fazer na hora de ler tais valores, é só, ler e invertê-los, para isso antes temos que escrever uma função para efetuar essa tarefa:

> *png.c:*

```
...
void correct_litle_endian(Byte * bytes){
    char reverse[4];
    int i, r;
    for (i = 0, r = 3; i < 4 && r >= 0; i++, r--){
        reverse[i] = bytes[r];
    }
    for (i = 0; i < 4; i++)
        bytes[i] = reverse[i];
}
...

```

O próximo passo, é adicionar a função acima em `png.h` para armazenar nosso tipo em little endian:

```
void correct_litle_endian(Byte * bytes);

```

E por fim, inverter o trecho de bytes que queremos:

```
...
Chunk bloco;
fread(&bloco, 8, 1, image);

// Corrigindo bug de little endian
Byte * tamanho;
tamanho = (Byte *)&bloco; // O lenght fica no inicio do chunk
correct_litle_endian(tamanho);

// Criando buffer de dados com o tamanho lido
...

```

E agora iremos fazer o mesmo para o `cabecalho`:

![img](https://cdn-images-1.medium.com/max/800/0*XISWJaCYATfVtyMk.png)

> *Os valores selecionados sao os bytes de altura e largura do conteúdo do cabeçalho, e basicamente esses valores foram armazenados em* `**bloco.data**` *como* `**1d00 0000 1c00 0000**`*:*

```
...
if (strcmp(bloco.type, "IHDR"))
    die("Não foi possível ler o cabeçalho do arquivo");

IHDR * cabecalho = (IHDR*)bloco.data;
{
    Byte * altura, * largura;
    
    // A largura começa no 1º byte, mas aqui ele ficou no 4º byte
    largura = (Byte *)cabecalho+4; // ... 0000 001c           ...

    // A altura começa no 4º byte, mas aqui ele ficou no 1º byte
    altura = (Byte *)cabecalho;    // ...           0000 001d ...
    
    correct_litle_endian(altura);
    correct_litle_endian(largura);
}

return 0;
...

```

### Criando funções de abstração

###  

E já que isso tería que ser feito toda vez que fossemos ler um `IHDR` e até mesmo um `Chunk` comum, então vamos montar umas funções com esta estrutura para facilitar as coisas no futuro:

> *png.c*

```
...

void * next_chunk(FILE * image){
    Chunk* block;
    fread(block, 8, 1, image);
    
    // Corrigindo bug de little endian
    Byte * lenght = (Byte *)block;
    correct_litle_endian(lenght);
    
    // Tem que vir antes do data, para não corromper os dados do mesmo
    block->type[4] = 0;
    block->data = (char *)malloc(block->lenght);
    
    // Lendo os dados do chunk
    fread(block->data, block->lenght, 1, image);
    
    // Lendo o crc
    fread(&block->crc, 4, 1, image);     // Salvando dados no cabeçalho
    return block;
}

void trash_chunk(Chunk * block){
    free(block->data);
    free(block);
}

void* to_IHDR(const char * raw_data){
    Dimentions* data = (Dimentions*)raw_data;
    correct_litle_endian(data->width);
    correct_litle_endian(data->height);
    IHDR* header = (IHDR*)raw_data;
    return header;
}

...

```

> *png.h*

```
...
typedef struct {
    Byte   width[4]; // Comprimento
    Byte  height[4]; // Altura
} SIZE_RAW;
typedef Dimentions SIZE_RAW;
...

```

> *main.c (substitua toda a função main)*

```
// Criando o arquivo e abrindo a imagem
FILE * image = fopen("image.png", "rb");
if (!image)
    die("Não foi possível ler a imagem");
if (!is_PNG(image))
    die("A imagem não é uma PNG");Chunk * bloco = next_chunk(image);

if (strcmp(bloco.type, "IHDR"))
    die("Não foi possível ler o cabeçalho do arquivo");
IHDR * cabecalho = to_IHDR(bloco->data);

printf("Tamanho do cabecalho: %i, Largura: %i, Altura: %i\n",
        bloco->lenght, cabecalho->height, cabecalho->width);

trash_chunk(bloco);
return 0;

```

### Para que servem os dados de um `IHDR`?

Bom, no último capítulo vimos as estruturas básicas de uma PNG (os chunks e o signature), e aprendemos a extrair o primeiro `Chunk` de toda PNG, o `IHDR`, e inclusive aprendemos neste capítulo, como corrigir um bug que nos atrapalharia muito na leitura dos dados da imagem (`IDAT`).

Dois desses dados são extremamente óbvios e tenho certeza que você já sabe o objetivo (altura e largura), mas os outros 5 dados são um pouco confusos, então vamos nos aprofundar mais sobre eles.

### Bit depth

A profundidade de bits é um valor inteiro que tem o número de bits (é bit mesmo, não bytes) por `sample`, e só são válidos valores entre `1, 2, 4` e `16`, sendo que cada tipo de cor pode aceitar um número específico de profundidade de bits.

> *O* `*sample*` *é um byte que faz parte de algum tipo de cor, sendo que um tipo como o RGB possue* `*3 samples*`*, enquanto tipos como o* `*grayscale*` *possue apenas* `*1*`*.*

### Color type

Este campo, recebe um valor único da imagem que deve estar entre `0, 2, 3, 4, 6` onde:

`0` é usado para escala de cinzas, e geralmente é um valor só para cada `sample`.

> *Válido para todas as profundidades de bit.*

`2` é usado quando o campo de dados usa os valores `R,G,B` (vermelho, verde e azul) para representar os pixels.

> *Vádido apenas para profundidade* `**8**` *ou* `**16**`*.*

`3` quando as cores são representadas pelo campo de paleta (`PLTE`).

> *Válido para as profundidades* `**1,2,4**` *e* `**8**`*.*

`4` para escala de cinzas com camada transparente.

> *Vádido apenas para profundidade* `**8**` *ou* `**16**`*.*

`6` para `r,g,b` com camada transparente.

> *Vádido apenas para profundidade* `**8**` *ou* `**16**`*.*

### Interlace method

O método de intrelaçamento é um byte que indica a forma que a ordem de dados da imagem está indexada do campo de dados, podendo ter 2 tipos básicos, `0`(sem intrelaçamento) ou `1`(método `Adam7`).

### Compression method

O método de compressão é bem óbvio, basicamente se refere a forma de compressão dos dados do campo de dados, como existem uma quantidade bem alta de compressores suportados, não irei citá-los aqui além do `0` que é quando não existe compressão.

### Filter method

O método de filtragem é a forma com que os dados da imagem seríam filtrados, e assim como no [Método de compressão](https://chumbucket.com.br/post/como-editar-arquivos-binarios-em-c-2/#compressionmethod), existem muitos métodos, então só citarei o `0`, quando não há método de filtragem.

### Tornando o código mais humano

E já que temos esses dados agora, vamos deixar nosso código mais humano e alterar o tipo `IHDR` para o seguinte código:

```
...
typedef enum {
    GrayScale = 0,
    RGB = 2,
    Pallete = 3,
    GrayScaleAlpha = 4,
    RGBAlpha = 6
} ColorType;
typedef enum {
    NoInterlace = 0,
    Adam7 = 1
} Interlace;
typedef struct {
    uint32_t          width; // Comprimento
    uint32_t         height; // Altura
    Byte              depth; // Profundidade de bits
    ColorType         color; // Tipo de cor
    Interlace     interlace; // Tipo de intrelaçamento
    Byte             filter; // Tipo de cor
    Byte        compression; // Tipo de compressão
} IHDR;
...

```

> *Assim poderemos usar esses valores mais intuitivos para ler os dados do* `*IHDR*`

### Conclusão

E eu sei que agora você deve estar se perguntando como funciona esse lance de estruturação dos dados, e como interpretá-los e enfim… Mas eu vou ficando por aqui e no próximo capítulo lhes mostrarei como vai funcionar isso e indicar para onde vocês devem ir caso queiram adicionar suporte completo as suas bibliotecas.

O código completo está [nesse gist](https://gist.github.com/plankiton/8195dbe53d129ed65acb1011bd42b460) citado no início do post.

Preparem-se porque no próximo capítulo iremos falar sobre o campo de dados (`IDAT`).

**Boa sorte e até o próximo capítulo da série!!**