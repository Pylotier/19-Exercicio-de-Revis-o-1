CREATE DATABASE ex9
GO
USE ex9
GO
CREATE TABLE editora (
codigo INT NOT NULL,
nome VARCHAR(30) NOT NULL,
site VARCHAR(40) NULL
PRIMARY KEY (codigo)
)
GO
CREATE TABLE autor (
codigo INT NOT NULL,
nome VARCHAR(30) NOT NULL,
biografia VARCHAR(100) NOT NULL
PRIMARY KEY (codigo)
)
GO
CREATE TABLE estoque (
codigo INT NOT NULL,
nome VARCHAR(100) NOT NULL UNIQUE,
quantidade INT NOT NULL,
valor DECIMAL(7,2) NOT NULL CHECK(valor > 0.00),
codEditora INT NOT NULL,
codAutor INT NOT NULL,
PRIMARY KEY (codigo),
FOREIGN KEY (codEditora) REFERENCES editora (codigo),
FOREIGN KEY (codAutor) REFERENCES autor (codigo)
)
GO
CREATE TABLE compra (
codigo INT NOT NULL,
codEstoque INT NOT NULL,
qtdComprada INT NOT NULL,
valor DECIMAL(7,2) NOT NULL,
dataCompra DATE NOT NULL
PRIMARY KEY (codigo, codEstoque, dataCompra)
FOREIGN KEY (codEstoque) REFERENCES estoque (codigo)
)
GO
INSERT INTO editora VALUES
(1,'Pearson','www.pearson.com.br'),
(2,'Civilização Brasileira',NULL),
(3,'Makron Books','www.mbooks.com.br'),
(4,'LTC','www.ltceditora.com.br'),
(5,'Atual','www.atualeditora.com.br'),
(6,'Moderna','www.moderna.com.br')
GO
INSERT INTO autor VALUES
(101,'Andrew Tannenbaun','Desenvolvedor do Minix'),
(102,'Fernando Henrique Cardoso','Ex-Presidente do Brasil'),
(103,'Diva Marilia Flemming','Professora adjunta da UFSC'),
(104,'David Halliday','Ph.D. da University of Pittsburgh'),
(105,'Alfredo Steinbruch','Professor de Matematica da UFRS e da
PUCRS'),
(106,'Willian Roberto Cereja','Doutorado em Linguistica Aplicada e
Estudos da Linguagem'),
(107,'William Stallings','Doutorado em Ciencias da Computacão pelo
MIT'),
(108,'Carlos Morimoto','Criador do Kurumin Linux')
GO
INSERT INTO estoque VALUES
(10001,'Sistemas Operacionais Modernos',4,108.00,1,101),
(10002,'A Arte da Política',2,55.00,2,102),
(10003,'Calculo A',12,79.00,3,103),
(10004,'Fundamentos de Fisica I',26,68.00,4,104),
(10005,'Geometria Analitica',1,95.00,3,105),
(10006,'Gramática Reflexiva',10,49.00,5,106),
(10007,'Fundamentos de Fisica III',1,78.00,4,104),
(10008,'Calculo B',3,95.00,3,103)
GO
INSERT INTO compra VALUES
(15051,10003,2,158.00, CAST(N'2026-07-04' AS DATE)),
(15051,10008,1,95.00, CAST(N'2026-07-04' AS DATE)),
(15051,10004,1,68.00, CAST(N'2026-07-04' AS DATE)),
(15051,10007,1,78.00, CAST(N'2026-07-04' AS DATE)),
(15052,10006,1,49.00, CAST(N'2026-07-05' AS DATE)),
(15052,10002,3,165.00, CAST(N'2026-07-05' AS DATE)),
(15053,10001,1,108.00, CAST(N'2026-07-05' AS DATE)),
(15054,10003,1,79.00, CAST(N'2026-08-06' AS DATE)),
(15054,10008,1,95.00, CAST(N'2026-08-06' AS DATE))

-- 1) Consultar nome, valor unitário, nome da editora e nome do autor dos livros do
-- estoque que foram vendidos. Não pode haver repetições.
-- editora, autor, estoque, 
SELECT DISTINCT estoque.nome, estoque.valor, editora.nome, autor.nome, compra.qtdComprada FROM compra INNER JOIN estoque
ON estoque.codigo = compra.codEstoque
INNER JOIN editora
ON editora.codigo = estoque.codEditora
INNER JOIN autor
ON autor.codigo = estoque.codAutor

-- 2) Consultar nome do livro, quantidade comprada e valor de compra da compra 15051
SELECT est.nome, com.qtdComprada, est.valor, com.codigo FROM estoque AS est INNER JOIN compra AS com
ON est.codigo = com.codEstoque
WHERE com.codigo = 15051

-- 3) Consultar Nome do livro e site da editora dos livros da Makron books (Caso o site
-- tenha mais de 10 dígitos, remover o www.).
SELECT est.nome, edi.site, 
CASE
 WHEN LEN(edi.site) > 10 THEN SUBSTRING(edi.site, 5, LEN(edi.site))
ELSE edi.site
END AS 'Site'FROM estoque AS est INNER JOIN editora AS edi
ON edi.codigo = est.codEditora
WHERE edi.nome LIKE 'Makron%' 

-- 4) Consultar nome do livro e Breve Biografia do David Halliday
SELECT est.nome, aut.nome, aut.biografia FROM estoque AS est INNER JOIN autor AS aut
ON aut.codigo = est.codAutor
WHERE aut.nome = 'David Halliday'

-- 5) Consultar código de compra e quantidade comprada do livro Sistemas Operacionais Modernos
SELECT com.codigo, com.qtdComprada, est.nome FROM compra AS com INNER JOIN estoque AS est
ON est.codigo = com.codEstoque
WHERE est.nome = 'Sistemas Operacionais Modernos'

-- 6) Consultar quais livros não foram vendidos
SELECT est.nome FROM estoque AS est LEFT OUTER JOIN compra AS com
ON est.codigo = com.codEstoque
WHERE com.qtdComprada IS NULL

-- 7) Consultar quais livros foram vendidos e não estão cadastrados. Caso o nome dos
-- livros termine com espaço, fazer o trim apropriado.

SELECT 
CASE
 WHEN est.nome LIKE '% ' THEN RTRIM(LTRIM(est.nome))
ELSE est.nome
END AS nome, est.valor FROM estoque AS est RIGHT OUTER JOIN compra AS com
ON est.codigo = com.codEstoque
WHERE est.codigo IS NULL

-- 8) Consultar Nome e site da editora que não tem Livros no estoque (Caso o site tenha
-- mais de 10 dígitos, remover o www.)
SELECT edi.nome, 
CASE 
 WHEN LEN(edi.site) > 10 THEN SUBSTRING(edi.site, 5, LEN(edi.site))
ELSE edi.site
END AS 'site' FROM editora AS edi LEFT OUTER JOIN estoque AS est
ON edi.codigo = est.codEditora
WHERE est.codEditora IS NULL

-- 9) Consultar Nome e biografia do autor que não tem Livros no estoque (Caso a
-- biografia inicie com Doutorado, substituir por Ph.D.)
SELECT aut.nome, 
CASE
 WHEN aut.biografia LIKE 'Doutorado%' THEN 'Ph.D'
ELSE aut.biografia
END as biografia FROM autor AS aut LEFT OUTER JOIN estoque AS est
ON aut.codigo = est.codAutor
WHERE est.codAutor IS NULL

-- 10) Consultar o nome do Autor, e o maior valor de Livro no estoque. Ordenar por valor
-- descendente
SELECT aut.nome, MAX(est.valor) AS valor_DESC FROM autor AS aut INNER JOIN estoque AS est
ON aut.codigo = est.codAutor
GROUP BY aut.nome, est.valor
ORDER BY est.valor DESC

-- 11) Consultar o código da compra, o total de livros comprados e a soma dos valores
-- gastos. Ordenar por Código da Compra ascendente.
SELECT com.codigo, SUM(com.qtdComprada) AS QtdComprada, SUM(com.valor) AS SomaValor FROM compra AS com
GROUP BY com.codigo
ORDER BY com.codigo ASC

-- 12) Consultar o nome da editora e a média de preços dos livros em estoque. Ordenar
-- pela Média de Valores ascendente.
SELECT edi.nome, AVG(est.valor) AS Media_Preco FROM editora AS edi INNER JOIN estoque AS est
ON edi.codigo = est.codEditora
GROUP BY edi.nome
ORDER BY AVG(est.valor)

-- 13) Consultar o nome do Livro, a quantidade em estoque o nome da editora, o site da
-- editora (Caso o site tenha mais de 10 dígitos, remover o www.), criar uma coluna
-- status onde:
-- Caso tenha menos de 5 livros em estoque, escrever Produto em Ponto de Pedido
-- Caso tenha entre 5 e 10 livros em estoque, escrever Produto Acabando
-- Caso tenha mais de 10 livros em estoque, escrever Estoque Suficiente
-- A Ordenacao deve ser por Quantidade ascendente
SELECT est.nome, est.quantidade, edi.nome, 
CASE
 WHEN LEN(edi.site) > 10 THEN SUBSTRING(edi.site, 5, LEN(edi.site))
 ELSE edi.site
END AS Site,
CASE
 WHEN SUM(est.quantidade) < 5 THEN CAST('Produto em Ponto de Pedido' AS VARCHAR(50))
 WHEN SUM(est.quantidade) >= 5 AND SUM(est.quantidade) <= 10 THEN CAST('Produto Acabando' AS VARCHAR(50))
 WHEN SUM(est.quantidade) > 10 THEN CAST('Estoque Suficiente' AS VARCHAR(50))
END AS Estado_Livro
FROM editora AS edi INNER JOIN estoque AS est
ON edi.codigo = est.codEditora
GROUP BY est.nome, est.quantidade, edi.nome, edi.site
ORDER BY est.quantidade ASC

-- 14) Para montar um relatório, é necessário montar uma consulta com a seguinte saída:
-- Código do Livro, Nome do Livro, Nome do Autor, Info Editora (Nome da Editora + Site)
-- de todos os livros
-- Só pode concatenar sites que não são nulos
SELECT est.codigo, est.nome, edi.nome, edi.nome + ' ' + edi.site AS Infor_Editora FROM editora AS edi RIGHT OUTER JOIN estoque AS est
ON edi.codigo = est.codEditora
WHERE edi.site IS NOT NULL

-- 15) Consultar Codigo da compra, quantos dias da compra até hoje e quantos meses da
-- compra até hoje
SELECT com.codigo, DATEDIFF(DAY, com.dataCompra, GETDATE()) AS DiasCompra, DATEDIFF(MONTH, com.dataCompra, GETDATE()) AS MesCompra FROM compra AS com

-- 16) Consultar o código da compra e a soma dos valores gastos das compras que somam
-- mais de 200.00
SELECT com.codigo, 
(SELECT SUM(com.valor) FROM compra AS com) AS TotalValor 
FROM compra AS com
GROUP BY com.codigo
HAVING SUM(com.valor) > 200.00
