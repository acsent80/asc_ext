﻿#Область ОписаниеОбработки

Функция СведенияОВнешнейОбработке() Экспорт

	ПараметрыРегистрации = ДополнительныеОтчетыИОбработки.СведенияОВнешнейОбработке("2.1.3.1");
	
	ПараметрыРегистрации.Вид = ДополнительныеОтчетыИОбработкиКлиентСервер.ВидОбработкиДополнительнаяОбработка();
	ПараметрыРегистрации.Версия = Метаданные().Комментарий;
	ПараметрыРегистрации.БезопасныйРежим = Истина;
	ПараметрыРегистрации.Информация = "Выгрузка документов РТУ по ОФУ в Астра";
	
	НоваяКоманда = ПараметрыРегистрации.Команды.Добавить();
	НоваяКоманда.Представление = Метаданные().Представление() + " - Открыть форму";
	НоваяКоманда.Идентификатор = Метаданные().Имя + "Форма";
	НоваяКоманда.Использование = ДополнительныеОтчетыИОбработкиКлиентСервер.ТипКомандыОткрытиеФормы();
	НоваяКоманда.ПоказыватьОповещение = Ложь;
	
	// Для запуска задания по каждой базе по отдельному расписанию
	МассивБаз = ПолучитьМассивБаз();
	Счетчик   = 0 ;
	Для каждого База из МассивБаз Цикл
		
		Счетчик = Счетчик + 1;
		
		НоваяКоманда = ПараметрыРегистрации.Команды.Добавить();
		НоваяКоманда.Представление = "Выгрузка документов РТУ по ОФУ (" + База + ")";
		НоваяКоманда.Идентификатор = "ВыгрузитьДокументыБаза" + Счетчик;
		НоваяКоманда.Использование = ДополнительныеОтчетыИОбработкиКлиентСервер.ТипКомандыВызовСерверногоМетода();
		НоваяКоманда.ПоказыватьОповещение = Ложь;
		
	КонецЦикла;

	Возврат ПараметрыРегистрации;

КонецФункции

Процедура ВыполнитьКоманду(ИдентификаторКоманды, ПараметрыКоманды = Неопределено) Экспорт 
	
	НомерБазы = Прав(ИдентификаторКоманды, 1);
	
	Параметры = Новый Структура;
	Параметры.Вставить("База", ПолучитьБазу(НомерБазы));
	
	ВыгрузитьДокументы(Параметры);
		
КонецПроцедуры	

#КонецОбласти

Функция ПолучитьМассивБаз()
	
	МассивБаз = Новый Массив;
	МассивБаз.Добавить("ASTRA ШкодаC и ДЦ ЭЛА");
	МассивБаз.Добавить("ASTRA Инфинити-Ленинский");
	МассивБаз.Добавить("ASTRA Внуково - Обручева");
	МассивБаз.Добавить("ASTRA Порше");
	МассивБаз.Добавить("ASTRA Химки");
	
КонецФункции

Функция ПолучитьБазу(НомерБазы)
	
	Если ЗначениеЗаполнено(НомерБазы) Тогда
		МассивБаз = ПолучитьМассивБаз();
		База = Справочники.ВнешниеИнформационныеБазы.НайтиПоНаименованию(МассивБаз[НомерБазы - 1]);
	Иначе
		База = Неопределено;
	КонецЕсли;	
	
КонецФункции	

Процедура ВыгрузитьДокументы(Параметры, АдресРезультата = Неопределено) Экспорт
	
	Тест_КоличествоСтрок = 0;
	Параметры.Свойство("Тест_КоличествоСтрок", Тест_КоличествоСтрок);
	
	ТекстЗапроса =
	"ВЫБРАТЬ //ПЕРВЫЕ
	|	Рег.ИспользуемаяИБ КАК База,
	|	Рег.Элемент КАК Элемент
	|ИЗ
	|	РегистрСведений.ИзмененныеОбъектыДляВыгрузки КАК Рег
	|{ГДЕ
	|	Рег.ИспользуемаяИБ.*}";
	
	Если ЗначениеЗаполнено(Тест_КоличествоСтрок) Тогда
		ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "//ПЕРВЫЕ", "ПЕРВЫЕ " + Формат(Тест_КоличествоСтрок, "ЧГ=0"));
	КонецЕсли;	
	
	Запрос = Новый ПостроительЗапроса;
	Запрос.Текст = ТекстЗапроса;
	
	Если ЗначениеЗаполнено(Параметры.База) Тогда
		
		ЭлементОтбора = Запрос.Отбор.Добавить("ИспользуемаяИБ");
		ЭлементОтбора.Установить(Параметры.База, Истина);
		
	Иначе
		
		ТипБД = Справочники.ТипыБазДанных.НайтиПоНаименованию("Astra");
		
		ЭлементОтбора = Запрос.Отбор.Добавить("ИспользуемаяИБ.ТипБД");
		ЭлементОтбора.Установить(ТипБД, Истина);
		
	КонецЕсли;	
	
	Запрос.Выполнить();
	Выборка = Запрос.Результат.Выбрать();
	
	Кэш = Новый Структура;
	Кэш.Вставить("Соединения", Новый Соответствие);
	Кэш.Вставить("БазыАстра",  Новый Соответствие);
	
	ДопПараметры = Новый Структура;
	ДопПараметры.Вставить("СвойствоСтраховая", ПланыВидовХарактеристик.ДополнительныеРеквизитыИСведения.НайтиПоРеквизиту("Имя", "Страховая"));
	ДопПараметры.Вставить("СвойствоIDПроекта", ПланыВидовХарактеристик.ДополнительныеРеквизитыИСведения.НайтиПоРеквизиту("Имя", "ID_Проекта"));
	
	Счетчик = 0;
	Всего   = Выборка.Количество();
	
	Пока Выборка.Следующий() Цикл
		
		Если Параметры.ВыводитьСообщения Тогда
			Сообщение = Новый СообщениеПользователю;
			Сообщение.Текст = Строка(Выборка.Элемент);
			Сообщение.КлючДанных = Выборка.Элемент;
			Сообщение.Сообщить();
		КонецЕсли;
		
		ВыгрузитьДокумент(Выборка.Элемент, Выборка.База, ДопПараметры, Кэш);
		
		Счетчик = Счетчик + 1;
		ПроцентВыполнения = Окр(100 * Счетчик / Всего, 2);
		ДлительныеОперации.СообщитьПрогресс(ПроцентВыполнения, "Выгружено " + Счетчик + " из " + Всего);
		
	КонецЦикла;	
	
	// Закроем все соединения
	Для каждого КлючИЗначение из Кэш.Соединения Цикл
		
		Попытка
			КлючИЗначение.Значение.Close();
		Исключение
		КонецПопытки;	
		
	КонецЦикла;	
	
КонецПроцедуры

Функция ПолучитьБазуАстра(ЦФО, Кэш)
	
	СпрСсылка = Кэш[ЦФО];
	Если СпрСсылка <> Неопределено Тогда
		Возврат СпрСсылка;
	КонецЕсли;	
	
	Запрос = Новый Запрос;
	Запрос.Параметры.Вставить("Организация", ЦФО);
	Запрос.Текст =
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	Рег.ЗначениеЭлементаНастройкиОтчета КАК ЗначениеЭлементаНастройкиОтчета
	|ИЗ
	|	РегистрСведений.НастройкаОбработкиОтчетов КАК Рег
	|ГДЕ
	|	Рег.ЭлементНастройкиОтчета = ЗНАЧЕНИЕ(Перечисление.ЭлементыНастройкиОтчета.ВнешняяИнформационнаяБаза)
	|	И Рег.Организация = &Организация
	|	И Рег.ШаблонДокументаБД = НЕОПРЕДЕЛЕНО";
	
	Результат = Запрос.Выполнить();
	Если НЕ Результат.Пустой() Тогда
		СпрСсылка = Результат.Выгрузить()[0][0];
	КонецЕсли;	
	
	Кэш.Вставить(ЦФО, СпрСсылка);
	
	Возврат СпрСсылка;
	
КонецФункции

Функция ПолучитьДанныеДокумента(Ссылка, Параметры)
	
	Запрос = Новый Запрос;
	Запрос.Параметры.Вставить("Ссылка", Ссылка);
	Запрос.Параметры.Вставить("СвойствоСтраховая", Параметры.СвойствоСтраховая);
	Запрос.Параметры.Вставить("СвойствоIDПроекта", Параметры.СвойствоIDПроекта);
	
	Если ТипЗнч(Ссылка) = Тип("ДокументСсылка.РеализацияТоваровУслуг") Тогда
		
		Запрос.Текст =
		"ВЫБРАТЬ
		|	НЕОПРЕДЕЛЕНО КАК Основание,
		|	Док.Дата КАК ОснованиеДата,
		|	Док.Дата КАК Дата,
		|	Док.Номер КАК Номер,
		|	Док.Организация КАК Организация,
		|	Док.ДоговорКонтрагента.Наименование КАК ДоговорНаименование,
		|	Док.ДоговорКонтрагента.ОсновнаяСтатьяИсполнение КАК Статья,
		|	Док.ДоговорКонтрагента.ОсновнойЦФО КАК ЦФО,
		|	ДоговорыСтраховая.Значение КАК Страховая,
		|	Док.СуммаДокумента КАК Сумма,
		|	ЕСТЬNULL(ДокУслуги.Номенклатура, ДокАгентскиеУслуги.Номенклатура) КАК Номенклатура,
		|	СпрНоменклатура.НоменклатурнаяГруппа.Наименование КАК НоменклатураНГ,
		|	ЕСТЬNULL(ДокУслуги.Сумма, 0) КАК СуммаУслуги,
		|	ЕСТЬNULL(ДокУслуги.Содержание, ДокАгентскиеУслуги.Содержание) КАК Содержание,
		|	Страховые.ИНН КАК СтраховаяИНН,
		|	Страховые.КПП КАК СтраховаяКПП,
		|	Страховые.Наименование КАК СтраховаяНаименование,
		|	ДопСведенияIDПроекта.Значение КАК IDПроекта,
		|	Док.Комментарий КАК Комментарий
		|ИЗ
		|	Документ.РеализацияТоваровУслуг КАК Док
		|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.РеализацияТоваровУслуг.Услуги КАК ДокУслуги
		|		ПО (ДокУслуги.Ссылка = Док.Ссылка)
		|			И (ДокУслуги.НомерСтроки = 1)
		|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.РеализацияТоваровУслуг.АгентскиеУслуги КАК ДокАгентскиеУслуги
		|		ПО (ДокАгентскиеУслуги.Ссылка = Док.Ссылка)
		|			И (ДокАгентскиеУслуги.НомерСтроки = 1)
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ДоговорыКонтрагентов.ДополнительныеРеквизиты КАК ДоговорыСтраховая
		|		ПО Док.ДоговорКонтрагента = ДоговорыСтраховая.Ссылка
		|			И (ДоговорыСтраховая.Свойство = &СвойствоСтраховая)
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Контрагенты КАК Страховые
		|		ПО (ДоговорыСтраховая.Значение = Страховые.Ссылка)
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ДополнительныеСведения КАК ДопСведенияIDПроекта
		|		ПО Док.Ссылка = ДопСведенияIDПроекта.Объект
		|			И (ДопСведенияIDПроекта.Свойство = &СвойствоIDПроекта)
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Номенклатура КАК СпрНоменклатура
		|		ПО (ЕСТЬNULL(ДокАгентскиеУслуги.Номенклатура, ДокУслуги.Номенклатура) = СпрНоменклатура.Ссылка)
		|ГДЕ
		|	Док.Ссылка = &Ссылка";
		
	ИначеЕсли ТипЗнч(Ссылка) = Тип("ДокументСсылка.КорректировкаРеализации") Тогда	
		
		Запрос.Текст =
		"ВЫБРАТЬ
		|	Док.ДокументРеализации.Дата КАК ОснованиеДата,
		|	Док.ДокументРеализации КАК Основание,
		|	Док.Организация КАК Организация,
		|	Док.ДоговорКонтрагента.Наименование КАК ДоговорНаименование,
		|	Док.ДоговорКонтрагента.ОсновнаяСтатьяИсполнение КАК Статья,
		|	Док.ДоговорКонтрагента.ОсновнойЦФО КАК ЦФО,
		|	ДоговорыСтраховая.Значение КАК Страховая,
		|	Док.СуммаДокумента КАК Сумма,
		|	ЕСТЬNULL(ДокУслуги.Сумма, 0) КАК СуммаУслуги,
		|	ЕСТЬNULL(ДокУслуги.Содержание, ДокАгентскиеУслуги.Содержание) КАК Содержание,
		|	Страховые.ИНН КАК СтраховаяИНН,
		|	Страховые.КПП КАК СтраховаяКПП,
		|	Страховые.Наименование КАК СтраховаяНаименование,
		|	ДопСведенияIDПроекта.Значение КАК IDПроекта,
		|	Док.Комментарий КАК Комментарий
		|ИЗ
		|	Документ.КорректировкаРеализации КАК Док
		|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.КорректировкаРеализации.Услуги КАК ДокУслуги
		|		ПО (ДокУслуги.Ссылка = Док.Ссылка)
		|			И (ДокУслуги.НомерСтроки = 1)
		|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.КорректировкаРеализации.АгентскиеУслуги КАК ДокАгентскиеУслуги
		|		ПО (ДокАгентскиеУслуги.Ссылка = Док.Ссылка)
		|			И (ДокАгентскиеУслуги.НомерСтроки = 1)
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ДоговорыКонтрагентов.ДополнительныеРеквизиты КАК ДоговорыСтраховая
		|		ПО Док.ДоговорКонтрагента = ДоговорыСтраховая.Ссылка
		|			И (ДоговорыСтраховая.Свойство = &СвойствоСтраховая)
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Контрагенты КАК Страховые
		|		ПО (ДоговорыСтраховая.Значение = Страховые.Ссылка)
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ДополнительныеСведения КАК ДопСведенияIDПроекта
		|		ПО Док.ДокументРеализации = ДопСведенияIDПроекта.Объект
		|			И (ДопСведенияIDПроекта.Свойство = &СвойствоIDПроекта)
		|ГДЕ
		|	Док.Ссылка = &Ссылка";
		
	ИначеЕсли ТипЗнч(Ссылка) = Тип("ДокументСсылка.ОперацияБух") Тогда	
	КонецЕсли;	
	
	СтрокаТЗ = Запрос.Выполнить().Выгрузить()[0];
	
	Результат = Новый Структура;
	Результат.Вставить("ГУИД", Строка(Ссылка.УникальныйИдентификатор()));
	
	Если НЕ ЗначениеЗаполнено(СтрокаТЗ.Основание) Тогда
		Результат.Вставить("ОснованиеГУИД", "00000000-0000-0000-0000-000000000000");
	Иначе                                    
		Результат.Вставить("ОснованиеГУИД", Строка(СтрокаТЗ.Основание.УникальныйИдентификатор()));
	КонецЕсли;	
	
	Результат.Вставить("Дата",           Формат(СтрокаТЗ.Дата, "ДФ=yyyyMMdd"));
	Результат.Вставить("Номер",          СтрокаТЗ.Номер);
	Результат.Вставить("ДЦ",             СтрокаТЗ.ЦФО);
	Результат.Вставить("ДЦГУИД",         Строка(СтрокаТЗ.ЦФО.УникальныйИдентификатор()));
	Результат.Вставить("ОснованиеДата",  Формат(СтрокаТЗ.ОснованиеДата, "ДФ=yyyyMMdd"));
	Результат.Вставить("Статья",         Строка(СтрокаТЗ.Статья.УникальныйИдентификатор()));
	Результат.Вставить("Организация",    Строка(СтрокаТЗ.Организация.УникальныйИдентификатор()));
	Результат.Вставить("СтраховаяИНН",   СтрокаТЗ.СтраховаяИНН);
	Результат.Вставить("СтраховаяКПП",   СтрокаТЗ.СтраховаяКПП);
	Результат.Вставить("Страховая",      СтрЗаменить(СтрокаТЗ.СтраховаяНаименование, "'", ""));
	Результат.Вставить("Сумма",          Формат(СтрокаТЗ.Сумма, "ЧРД=.; ЧН=0; ЧГ=0"));
	Результат.Вставить("СуммаКВ",        Формат(СтрокаТЗ.СуммаУслуги, "ЧРД=.; ЧН=0; ЧГ=0"));
	Результат.Вставить("Договор",        СтрокаТЗ.ДоговорНаименование);
	
	Если НЕ ЗначениеЗаполнено(СтрокаТЗ.IDПроекта) Тогда
		Результат.Вставить("IDПроекта", "00000000-0000-0000-0000-000000000000");
	Иначе	
		Результат.Вставить("IDПроекта", СтрокаТЗ.IDПроекта);
	КонецЕсли;	
	
	Если СтрокаТЗ.НоменклатураНГ = "РИНГ" Тогда
		Результат.Вставить("Операция", "33115d62-5099-4089-9f17-fbffe3e48918");
		
	ИначеЕсли СтрокаТЗ.Комментарий = "Прямые расчеты с СК" Тогда	
		Результат.Вставить("Операция", "bae1c9a1-f049-4059-ba71-17e62bb13276");
		
	Иначе	
		Результат.Вставить("Операция", "0c10ae0f-8a51-4b29-aa2d-b36b16880642");
	КонецЕсли;	
	
	Массив = СтрРазделить(СтрокаТЗ.Содержание, ",");
	Если Массив.Количество() = 0 Тогда
		Результат.Вставить("VIN", "");
	Иначе	
		Результат.Вставить("VIN", СокрЛП(Массив[0]));
	КонецЕсли;	
	
	Возврат Результат;
	
КонецФункции	

Процедура ВыгрузитьДокумент(Ссылка, База, Параметры, Кэш)
	
	Соединение = Кэш.Соединения[База];
	Если Соединение = Неопределено Тогда
		
		СтрокаСоединения = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(База, "СтрокаПодключения");
		
		Соединение = Новый COMОбъект("ADODB.Connection");
		Соединение.Open(СтрокаСоединения);
		
		Кэш.Соединения.Вставить(База, Соединение);
		
	КонецЕсли;	
	
	Данные = ПолучитьДанныеДокумента(Ссылка, Параметры);
	
	БазаАстра = ПолучитьБазуАстра(Данные.ДЦ, Кэш.БазыАстра);
	Если БазаАстра = База Тогда
		Статус = "Добавить";
	Иначе	
		Статус = "Удалить";
	КонецЕсли;
	
	ТекстЗапроса =
	"DECLARE
	|	@CurrentDocument_ID  uniqueidentifier = '" + Данные.ГУИД + "',
	|	@ParentDocument_ID   uniqueidentifier = '" + Данные.ОснованиеГУИД + "',
	|	@DocumentDate        datetime         = '" + Данные.Дата + "',
	|	@DocumentNumber      varchar(40)      = '" + Данные.Номер + "',
	|	@Status              varchar(15)      = '" + Статус + "',
	|	@SaleInsuranceDate   datetime         = '" + Данные.ОснованиеДата + "',     
	|	@Center_ID           uniqueidentifier = '" + Данные.ДЦГУИД + "',
	|	@Project_ID          uniqueidentifier = '" + Данные.IDПроекта + "',
	|	@FCArticle_ID        uniqueidentifier = '" + Данные.Статья + "',
	|	@BusinessTransaction uniqueidentifier = '" + Данные.Операция + "',
	|	@Firm_ID             uniqueidentifier = '" + Данные.Организация + "',
	|	@SupplierINN         varchar(20)      = '" + Данные.СтраховаяИНН + "',
	|	@SupplierKPP         varchar(20)      = '" + Данные.СтраховаяКПП + "',
	|	@SupplierName        varchar(255)     = '" + Данные.Страховая + "',
	|	@SummaSalel          money            = "  + Данные.Сумма + ",
	|	@SummaKV             money            = "  + Данные.СуммаКВ + ",
	|	@VIN                 varchar(17)      = '" + Данные.VIN + "',
	|	@PoliceNumber        varchar(40)      = '" + Данные.Договор + "',
	|	@PoliceSeria         varchar(40)      = '',
	|	@BlankNumber         varchar(40)      = '" + Данные.Договор + "'
	|
	|EXEC [uho].[PR_UHSaleInsurance_Create] 
	|	@CurrentDocument_ID,
	|	@ParentDocument_ID,
	|	@DocumentDate,
	|	@DocumentNumber,
	|	@Status,
	|	@SaleInsuranceDate,     
	|	@Center_ID,
	|	@Project_ID,
	|	@FCArticle_ID,
	|	@BusinessTransaction,
	|	@Firm_ID,
	|	@SupplierINN,
	|	@SupplierKPP,
	|	@SupplierName,
	|	@SummaSalel,
	|	@SummaKV,
	|	@VIN,
	|	@PoliceNumber,
	|	@PoliceSeria,
	|	@BlankNumber";
	
	Соединение.Execute(ТекстЗапроса);
	
	Запись = РегистрыСведений.ИзмененныеОбъектыДляВыгрузки.СоздатьМенеджерЗаписи();
	Запись.ИспользуемаяИБ = База;
	Запись.Элемент        = Ссылка;
	Запись.Удалить();
	
КонецПроцедуры

