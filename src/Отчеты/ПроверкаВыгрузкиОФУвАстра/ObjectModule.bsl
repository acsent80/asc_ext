﻿
#Область ОписаниеОбработки

Функция СведенияОВнешнейОбработке() Экспорт
	
	ПараметрыРегистрации = ДополнительныеОтчетыИОбработки.СведенияОВнешнейОбработке("2.2.2.1");
	
	// HKEY_LOCAL_MACHINE\SOFTWARE\Classes\ADODB.Connection
	Разрешение = РаботаВБезопасномРежиме.РазрешениеНаСозданиеCOMКласса("ADODB.Connection", "{00000514-0000-0010-8000-00AA006D2EA4}");
	ПараметрыРегистрации.Разрешения.Добавить(Разрешение);
	
	ПараметрыРегистрации.Вид = ДополнительныеОтчетыИОбработкиКлиентСервер.ВидОбработкиДополнительныйОтчет();
	ПараметрыРегистрации.Версия = Метаданные().Комментарий;
	ПараметрыРегистрации.БезопасныйРежим = Истина;
	ПараметрыРегистрации.Информация = Метаданные().Представление();
	ПараметрыРегистрации.Вставить("ХранилищеВариантов", "ХранилищеВариантовОтчетов");

	НоваяКоманда = ПараметрыРегистрации.Команды.Добавить();
	НоваяКоманда.Представление = Метаданные().Представление();
	НоваяКоманда.Идентификатор = Метаданные().Имя;
	НоваяКоманда.Использование = ДополнительныеОтчетыИОбработкиКлиентСервер.ТипКомандыОткрытиеФормы();
	НоваяКоманда.ПоказыватьОповещение = Ложь;
	
	Возврат ПараметрыРегистрации;
	
КонецФункции

#КонецОбласти

Функция ГУИД(Знач ГУИДСтр)
	
	ГУИДСтр = СтрЗаменить(ГУИДСтр, "{", "");
	ГУИДСтр = СтрЗаменить(ГУИДСтр, "}", "");
	
	Возврат Новый УникальныйИдентификатор(ГУИДСтр);
	
КонецФункции	

Функция ИнициализироватьТаблицуАстра()
	
	ТипДокументы = Новый Массив;
	ТипДокументы.Добавить(Тип("ДокументСсылка.АСЦ_ПлановоеНачислениеКВ"));
	ТипДокументы.Добавить(Тип("Строка"));
	
	ТаблицаДанных = Новый ТаблицаЗначений;
	ТаблицаДанных.Колонки.Добавить("Тип",          Новый ОписаниеТипов("Строка"));
	ТаблицаДанных.Колонки.Добавить("Дата",         Новый ОписаниеТипов("Дата"));
	ТаблицаДанных.Колонки.Добавить("Организация",  Новый ОписаниеТипов("СправочникСсылка.Организации"));
	ТаблицаДанных.Колонки.Добавить("Статья",       Новый ОписаниеТипов("СправочникСсылка.СтатьиДоходовИРасходов"));
	ТаблицаДанных.Колонки.Добавить("ДЦ",           Новый ОписаниеТипов("СправочникСсылка.Проекты"));
	ТаблицаДанных.Колонки.Добавить("Договор",      Новый ОписаниеТипов("Строка"));
	ТаблицаДанных.Колонки.Добавить("Документ",     Новый ОписаниеТипов(ТипДокументы));
	ТаблицаДанных.Колонки.Добавить("Сумма",        Новый ОписаниеТипов("Число"));
	ТаблицаДанных.Колонки.Добавить("СуммаКВ",      Новый ОписаниеТипов("Число"));
	ТаблицаДанных.Колонки.Добавить("СуммаКВФакт",  Новый ОписаниеТипов("Число"));
	ТаблицаДанных.Колонки.Добавить("СуммаАстра",   Новый ОписаниеТипов("Число"));
	ТаблицаДанных.Колонки.Добавить("СуммаКВАстра", Новый ОписаниеТипов("Число"));
	ТаблицаДанных.Колонки.Добавить("СуммаКВФактАстра", Новый ОписаниеТипов("Число"));
	ТаблицаДанных.Колонки.Добавить("ВнешнийИД",    Новый ОписаниеТипов("Строка"));
	
	Возврат ТаблицаДанных;
	
КонецФункции	

Процедура ПолучитьДанныеАстра_Страховки(ТаблицаДанных, База, Параметры)
	
	ТекстЗапроса =
	"SELECT
	|	CAST(tab.CurrentDocument_ID as VARCHAR(36)) as CurrentDocument_ID
	|	,CAST(tab.Project_ID as VARCHAR(36)) as Project_ID
	|	,CAST(tab.Center_ID as VARCHAR(36)) as Center_ID
	|	,CAST(tab.BusinessTransaction_DocSubType_ID as VARCHAR(36)) as BusinessTransaction_DocSubType_ID
	|	,CAST(tab.Firm_ID as VARCHAR(36)) as Firm_ID
	|	,tab.PoliceNumber
	|	,CAST(tab.FCArticle_ID as VARCHAR(36)) as FCArticle_ID 
	|	,tab.SaleInsuranceDate
	|	,tab.SummaSalel
	|	,tab.SummaKV
	|	,tab.DocumentStateName
	|FROM 
	|	uho.UHSaleInsurance as tab
	|WHERE
	|	tab.SaleInsuranceDate BETWEEN &Дата1 AND &Дата2
	|	AND tab.DocumentStateName IN ('Отработан')";
	
	ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&Дата1", ИнтеграцияСВнешнимиСистемамиУХ.АСЦ1_асцПолучитьТекстПараметра(Параметры.Дата1, "SQLOLEDB"));
	ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&Дата2", ИнтеграцияСВнешнимиСистемамиУХ.АСЦ1_асцПолучитьТекстПараметра(Параметры.Дата2, "SQLOLEDB"));
	
	СтрокаСоединения = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(База, "СтрокаПодключения");
	
	Соединение = Новый COMОбъект("ADODB.Connection");
	Соединение.Open(СтрокаСоединения);
	
	НаборЗаписей = Соединение.Execute(ТекстЗапроса);
	Пока НЕ НаборЗаписей.EOF Цикл
		
		НоваяСтрока = ТаблицаДанных.Добавить();
		НоваяСтрока.Тип  = "Страховки";
		НоваяСтрока.Дата = НаборЗаписей.Fields("SaleInsuranceDate").Value;
		
		ОрганизацияГУИД = НаборЗаписей.Fields("Firm_ID").Value;
		НоваяСтрока.Организация = Справочники.Организации.ПолучитьСсылку(ГУИД(ОрганизацияГУИД));
		
		ДЦГУИД = НаборЗаписей.Fields("Center_ID").Value;
		НоваяСтрока.ДЦ = Справочники.Проекты.ПолучитьСсылку(ГУИД(ДЦГУИД));
		
		СтатьяГУИД = НаборЗаписей.Fields("FCArticle_ID").Value;
		НоваяСтрока.Статья = Справочники.СтатьиДоходовИРасходов.ПолучитьСсылку(ГУИД(СтатьяГУИД));
		
		ДокументГУИД = ГУИД(НаборЗаписей.Fields("CurrentDocument_ID").Value);
		НоваяСтрока.Документ     = Документы.АСЦ_ПлановоеНачислениеКВ.ПолучитьСсылку(ДокументГУИД);
		Если НЕ ОбщегоНазначения.СсылкаСуществует(НоваяСтрока.Документ) Тогда
			НоваяСтрока.Документ = НаборЗаписей.Fields("CurrentDocument_ID").Value;
		КонецЕсли;
		
		НоваяСтрока.Договор      = НаборЗаписей.Fields("PoliceNumber").Value;
		НоваяСтрока.СуммаАстра   = НаборЗаписей.Fields("SummaSalel").Value;
		НоваяСтрока.СуммаКВАстра = НаборЗаписей.Fields("SummaKV").Value;
		
		НаборЗаписей.MoveNext();
		
	КонецЦикла;
	
	НаборЗаписей.Close();
	
КонецПроцедуры	

Процедура ПолучитьДанныеАстра_КВБанков(ТаблицаДанных, База, Параметры)
	
	ТекстЗапроса =
	"SELECT
	|	CAST(tab.CarSale_ID as VARCHAR(36)) as CarSale_ID
	|	,CAST(tab.CurrentDocument_ID as VARCHAR(36)) as CurrentDocument_ID
	|	,CAST(tab.FCArticle_ID as VARCHAR(36)) as [FCArticle_ID]
	|	,tab.DocumentBaseDate
	|	,tab.DocumentBaseNumber
	|	,tab.SummaKV
	|	,tab.SummaKVFact
	|FROM 
	|	[uho].[VW_UHSaleCredit] as tab
	|WHERE
	|	tab.DocumentBaseDate BETWEEN &Дата1 AND &Дата2
	|	AND tab.DocumentAllowedStateName IN ('Отработан')";
	
	ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&Дата1", ИнтеграцияСВнешнимиСистемамиУХ.АСЦ1_асцПолучитьТекстПараметра(Параметры.Дата1, "SQLOLEDB"));
	ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&Дата2", ИнтеграцияСВнешнимиСистемамиУХ.АСЦ1_асцПолучитьТекстПараметра(Параметры.Дата2, "SQLOLEDB"));
	
	СтрокаСоединения = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(База, "СтрокаПодключения");
	
	Соединение = Новый COMОбъект("ADODB.Connection");
	Соединение.Open(СтрокаСоединения);
	
	НаборЗаписей = Соединение.Execute(ТекстЗапроса);
	Пока НЕ НаборЗаписей.EOF Цикл
		
		НоваяСтрока = ТаблицаДанных.Добавить();
		НоваяСтрока.Тип  = "КВ банков";
		НоваяСтрока.Дата = НаборЗаписей.Fields("DocumentBaseDate").Value;
		
		СтатьяГУИД = НаборЗаписей.Fields("FCArticle_ID").Value;
		НоваяСтрока.Статья = Справочники.СтатьиДоходовИРасходов.ПолучитьСсылку(ГУИД(СтатьяГУИД));
		
		ДокументГУИД = ГУИД(НаборЗаписей.Fields("CurrentDocument_ID").Value);
		НоваяСтрока.Документ = Документы.АСЦ_ПлановоеНачислениеКВ.ПолучитьСсылку(ДокументГУИД);
		Если ОбщегоНазначения.СсылкаСуществует(НоваяСтрока.Документ) Тогда
			НоваяСтрока.ДЦ = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(НоваяСтрока.Документ, "ДЦ");
		Иначе	
			НоваяСтрока.Документ = НаборЗаписей.Fields("CurrentDocument_ID").Value;
		КонецЕсли;	
		
		НоваяСтрока.ВнешнийИД        = НаборЗаписей.Fields("CarSale_ID").Value;
		
		НоваяСтрока.СуммаАстра       = 0;
		НоваяСтрока.СуммаКВАстра     = НаборЗаписей.Fields("SummaKV").Value;
		НоваяСтрока.СуммаКВФактАстра = НаборЗаписей.Fields("SummaKVFact").Value;
		
		НаборЗаписей.MoveNext();
		
	КонецЦикла;
	
КонецПроцедуры	

Процедура ПриКомпоновкеРезультата(ДокументРезультат, ДанныеРасшифровки, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	Настройки = КомпоновщикНастроек.ПолучитьНастройки();
	
	База   = Настройки.ПараметрыДанных.НайтиЗначениеПараметра(Новый ПараметрКомпоновкиДанных("База")).Значение;
	Период = Настройки.ПараметрыДанных.НайтиЗначениеПараметра(Новый ПараметрКомпоновкиДанных("Период")).Значение;
	
	Параметры = Новый Структура;
	Параметры.Вставить("Дата1", Период.ДатаНачала);
	Параметры.Вставить("Дата2", Период.ДатаОкончания);
	
	ТаблицаАстра = ИнициализироватьТаблицуАстра();
	ПолучитьДанныеАстра_Страховки(ТаблицаАстра, База, Параметры);
	ПолучитьДанныеАстра_КВБанков(ТаблицаАстра, База, Параметры);
	
	ВнешниеНаборыДанных = Новый Структура;
	ВнешниеНаборыДанных.Вставить("Данные", ТаблицаАстра);
	
	КомпоновщикМакета = Новый КомпоновщикМакетаКомпоновкиДанных;
	МакетКомпоновки = КомпоновщикМакета.Выполнить(СхемаКомпоновкиДанных, Настройки, ДанныеРасшифровки);
	
	ПроцессорКомпоновки = Новый ПроцессорКомпоновкиДанных;
	ПроцессорКомпоновки.Инициализировать(МакетКомпоновки, ВнешниеНаборыДанных, ДанныеРасшифровки,);
	
	ПроцессорВывода = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВТабличныйДокумент;
	ПроцессорВывода.УстановитьДокумент(ДокументРезультат);
	
	ПроцессорВывода.Вывести(ПроцессорКомпоновки);
	
КонецПроцедуры
