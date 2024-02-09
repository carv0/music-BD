 
create table newname_-1646902579
(
   Festival_Festival_ID_   integer   not null,
   Tecnico_Numero_   Integer   not null,
 
   constraint PK_newname_-1646902579 primary key (Festival_Festival_ID_, Tecnico_Numero_)
);
 
create table newname_-38959399
(
   Festival_Festival_ID_   integer   not null,
   Espetador_Espetador_ID_   Integer   not null,
 
   constraint PK_newname_-38959399 primary key (Festival_Festival_ID_, Espetador_Espetador_ID_)
);
 
create table newname_49166588
(
   Tecnico_Numero_   Integer   not null,
   Palco_Codigo_   Integer   not null,
 
   constraint PK_newname_49166588 primary key (Tecnico_Numero_, Palco_Codigo_)
);
 
create table Festival
(
   Festival_ID   integer   not null,
   Nome   varchar(100)   null,
   Localizacao   varchar(100)   null,
   Local   varchar(100)   null,
   DataInicio   date   null,
   DataFim   date   null,
   Lotacao   Integer   null,
 
   constraint PK_Festival primary key (Festival_ID)
);
 
create table Edicao
(
   Festival_Festival_ID   integer   not null,
   Festival_Festival_ID   integer   not null,
   NumEdicao   Integer   not null,
 
   constraint PK_Edicao primary key (Festival_Festival_ID, Festival_Festival_ID, NumEdicao)
);
 
create table Tecnico
(
   Participante_Codigo   Integer   null,
   Numero   Integer   not null,
   Nome   varchar(100)   null,
 
   constraint PK_Tecnico primary key (Numero)
);
 
create table Espetador
(
   Espetador_ID   Integer   not null,
   Genero   varchar(100)   null,
 
   constraint PK_Espetador primary key (Espetador_ID)
);
 
create table Palco
(
   Codigo   Integer   not null,
   Nome   varchar(100)   null,
 
   constraint PK_Palco primary key (Codigo)
);
 
create table Pagante
(
   Espetador_Espetador_ID   Integer   not null,
   NumSerie   Integer   null,
   Idade   Integer   null,
 
   constraint PK_Pagante primary key (Espetador_Espetador_ID)
);
 
create table Convidado
(
   Espetador_Espetador_ID   Integer   not null,
   Bilhete_NumSerie   Integer   not null,
   Profissao   varchar(100)   null,
 
   constraint PK_Convidado primary key (Espetador_Espetador_ID)
);
 
create table Jornalista
(
   Espetador_Espetador_ID   Integer   not null,
   Data   date   null,
   Hora   time   null,
   NumCarteira   Integer   not null,
   Media   varchar(100)   null,
   CartaoLivreTransito   Integer   null,
 
   constraint PK_Jornalista primary key (NumCarteira)
);
 
create table Participante
(
   Jornalista_NumCarteira   Integer   not null,
   Participante_Codigo   Integer   not null,
   Data   date   null,
   Hora   time   null,
   Sequencia   Integer   null,
   Codigo   Integer   not null,
   Nome   varchar(100)   null,
   Estilo   varchar(100)   null,
   Cachet   Integer   null,
   HoraInicio   time   null,
   HoraFim   time   null,
 
   constraint PK_Participante primary key (Codigo)
);
 
create table Reportagem
(
   Jornalista_NumCarteira   Integer   not null,
   Reportagem_ID   integer   not null,
   Dia   varchar(100)   null,
 
   constraint PK_Reportagem primary key (Reportagem_ID)
);
 
create table Bilhete
(
   Edicao_Festival_Festival_ID   integer   not null,
   Edicao_NumEdicao   Integer   not null,
   Pagante_Espetador_Espetador_ID   Integer   not null,
   Convidado_Espetador_Espetador_ID   Integer   not null,
   NumSerie   Integer   not null,
   Designacao   varchar(100)   null,
   Preco   Integer   null,
 
   constraint PK_Bilhete primary key (NumSerie)
);
 
create table Tema
(
   Participante_Codigo   Integer   not null,
   Tema_ID   integer   not null,
   Sequencia   Integer   null,
   Titulo   varchar(100)   null,
 
   constraint PK_Tema primary key (Tema_ID)
);
 
create table ArtistaIndividual
(
   Participante_Codigo   Integer   not null,
   Nacionalidade   varchar(100)   null,
 
   constraint PK_ArtistaIndividual primary key (Participante_Codigo)
);
 
create table Grupo
(
   Participante_Codigo   Integer   not null,
   NumElementos   Integer   null,
 
   constraint PK_Grupo primary key (Participante_Codigo)
);
 
create table Membro
(
   Grupo_Participante_Codigo   Integer   not null,
   Membro_ID   integer   not null,
   Nome   varchar(100)   null,
   Papel   varchar(100)   null,
   Instrumento   varchar(100)   null,
 
   constraint PK_Membro primary key (Grupo_Participante_Codigo, Membro_ID)
);
 
alter table newname_-1646902579
   add constraint FK_Festival_newname_-1646902579_Tecnico_ foreign key (Festival_Festival_ID_)
   references Festival(Festival_ID)
; 
alter table newname_-1646902579
   add constraint FK_Tecnico_newname_-1646902579_Festival_ foreign key (Tecnico_Numero_)
   references Tecnico(Numero)
;
 
alter table newname_-38959399
   add constraint FK_Festival_newname_-38959399_Espetador_ foreign key (Festival_Festival_ID_)
   references Festival(Festival_ID)
; 
alter table newname_-38959399
   add constraint FK_Espetador_newname_-38959399_Festival_ foreign key (Espetador_Espetador_ID_)
   references Espetador(Espetador_ID)
;
 
alter table newname_49166588
   add constraint FK_Tecnico_newname_49166588_Palco_ foreign key (Tecnico_Numero_)
   references Tecnico(Numero)
; 
alter table newname_49166588
   add constraint FK_Palco_newname_49166588_Tecnico_ foreign key (Palco_Codigo_)
   references Palco(Codigo)
;
 
 
alter table Edicao
   add constraint FK_Edicao_noname_Festival foreign key (Festival_Festival_ID, Festival_Festival_ID)
   references Festival(Festival_ID, Festival_ID)
;
 
alter table Tecnico
   add constraint FK_Tecnico_noname_Participante foreign key (Participante_Codigo)
   references Participante(Codigo)
;
 
 
 
alter table Pagante
   add constraint FK_Pagante_Espetador foreign key (Espetador_Espetador_ID)
   references Espetador(Espetador_ID)
;
 
alter table Convidado
   add constraint FK_Convidado_Espetador foreign key (Espetador_Espetador_ID)
   references Espetador(Espetador_ID)
; 
alter table Convidado
   add constraint FK_Convidado_noname_Bilhete foreign key (Bilhete_NumSerie)
   references Bilhete(NumSerie)
;
 
alter table Jornalista
   add constraint FK_Jornalista_Espetador foreign key (Espetador_Espetador_ID)
   references Espetador(Espetador_ID)
;
 
alter table Participante
   add constraint FK_Participante_noname_Jornalista foreign key (Jornalista_NumCarteira)
   references Jornalista(NumCarteira)
; 
alter table Participante
   add constraint FK_Participante_convida_Participante foreign key (Participante_Codigo)
   references Participante(Codigo)
;
 
alter table Reportagem
   add constraint FK_Reportagem_noname_Jornalista foreign key (Jornalista_NumCarteira)
   references Jornalista(NumCarteira)
;
 
alter table Bilhete
   add constraint FK_Bilhete_noname_Edicao foreign key (Edicao_Festival_Festival_ID, Edicao_NumEdicao)
   references Edicao(Festival_Festival_ID, NumEdicao)
; 
alter table Bilhete
   add constraint FK_Bilhete_noname_Pagante foreign key (Pagante_Espetador_Espetador_ID)
   references Pagante(Espetador_Espetador_ID)
; 
alter table Bilhete
   add constraint FK_Bilhete_noname_Convidado foreign key (Convidado_Espetador_Espetador_ID)
   references Convidado(Espetador_Espetador_ID)
;
 
alter table Tema
   add constraint FK_Tema_noname_Participante foreign key (Participante_Codigo)
   references Participante(Codigo)
;
 
alter table ArtistaIndividual
   add constraint FK_ArtistaIndividual_Participante foreign key (Participante_Codigo)
   references Participante(Codigo)
;
 
alter table Grupo
   add constraint FK_Grupo_Participante foreign key (Participante_Codigo)
   references Participante(Codigo)
;
 
alter table Membro
   add constraint FK_Membro_noname_Grupo foreign key (Grupo_Participante_Codigo)
   references Grupo(Participante_Codigo)
;
 
