# Canvas JavaScript, Criando um grafico radial



Hoje eu tive que enfrentar um probleminha bem chato, criar um grafico radial para uma pagina web, e tive um probleminha pra conseguir implementar tudo, então resolvi  escrever aqui como cheguei a solução e porque você não deveria ter ignorado as aulas de matemática do fundamental (pasmem, programação também vai exigir que você saiba).



O funcionamento do algoritmo vai ser um tanto complicado, vamos ter que pegar dados, e colocá-los encaixados no gráfico, por exemplo, isso:



| Faixa etaria    | Capacidade financeira média por mês |
| --------------- | ----------------------------------- |
| A - Adulto      | 10                                  |
| B - Adolescente | 5                                   |
| C - Criança     | 3                                   |

Nisso (Ou algo parecido):

![image-20210323132204949](/home/plankiton/.config/Typora/typora-user-images/image-20210323132204949.png)



E nós temos basicamente um circulo com as três medidas esperadas separadas por um angulo igual dentro de um circulo com um raio igual ao maior valor do gráfico, o equivalente a isso:

![image-20210323132822078](/home/plankiton/.config/Typora/typora-user-images/image-20210323132822078.png)

Pra criar a primeira parte do código vamos pegar a parte do gráfico que armazena o `5`, para todas as outras vai funcionar mais ou menos igual e eu vou tentar explicar essa diferença também.



## Trigonometria no triangulo retangulo



Então chega de lero-lero e vamos começar esse bagulho, antes de mais nada um resuminho sobre as aulas de trigonometria no triangulo retângulo pra vocês não ficarem perdidos (caso você lembre bem como funciona simplesmente ignora essa parte).



Se vocês notaram nós temos o tamaho do raio e a distância entre eles, por padrão nós temos o raio maior (`10`) começando do 0,0 (x, y respectivamente) até `0,10`, então temos como pegar a localização raio 5,  



## 