﻿
Процедура ЗаполнитьОтчет(ДокОбъект) Экспорт
	
	// Аналитика
	// Номенклатура, Контрагент, Договор, Страховая
	
	ТекстЗапроса =
	"SELECT
	|	tab.FULL_PREMIUM as FULL_PREMIUM,
	|	tab.PREMIUM_SUM as PREMIUM_SUM,
	|	tab.KV_RUB as KV_RUB,
	|	tab.PAY_DATE as PAY_DATE,
	|	CASE WHEN tab.INSUR_TYPE = 'пролонгация' 
	|		THEN 1
	|		ELSE 0
	|	END as Пролонгация,
	|	tab.TS_NEW as TS_NEW,
	|	tab.STORONNIY_CLIENT as STORONNIY_CLIENT,
	// Номенклатура
	|	tab.PRODUCT_NAME as PRODUCT_NAME,
	// Контрагент
	|	tab.SUBJECT_NAME as SUBJECT_NAME,
	|	'ФизическоеЛицо' as ЮрФизЛицо,
	// Договор
	|	tab.POLICY_NUMBER as POLICY_NUMBER,
	|	tab.DATE_SIGN as DATE_SIGN,
	|	tab.ACTION_BEGIN_DATE as ACTION_BEGIN_DATE,
	|	tab.ACTION_END_DATE as ACTION_END_DATE,
	|	'СПокупателем' as ВидДоговора,
	|	'643' as ВалютаКод,
	// Страховая
	|	tab.SK_NAME as SK_NAME,
	|	'ЮридическоеЛицо' as СК_ЮрФизЛицо
	|FROM 
	|	V_ASC_CONTRACT tab
	|WHERE
	|	tab.DATE_SIGN >= &ДатаНач
	|	AND tab.DATE_SIGN <= &ДатаКон
	|	AND tab.AGENT = &Организация";
	
	//Доп отбор для тестирования
	// например AND rownum <= 10  - выбираем только первые 10 записей
	Если ДокОбъект.ДополнительныеСвойства.Свойство("Тест_КоличествоСтрок") Тогда
		ТекстЗапроса = ТекстЗапроса + " AND rownum <= " + Формат(ДокОбъект.ДополнительныеСвойства.Тест_КоличествоСтрок, "ЧГ=0");
		ЗаписьЖурналаРегистрации("Заполнение отчета UNICUS_Contracts",
			УровеньЖурналаРегистрации.Предупреждение, Метаданные.Документы.НастраиваемыйОтчет, ДокОбъект.Ссылка, "Кол-во строк: " + ДокОбъект.ДополнительныеСвойства.Тест_КоличествоСтрок);
	КонецЕсли;	
	
	ТекстЗапроса = ТекстЗапроса + "
	|ORDER BY
	|	DATE_SIGN, SUBJECT_NAME";
	
	ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&ДатаНач", ИнтеграцияСВнешнимиСистемамиУХ.АСЦ1_асцПолучитьТекстПараметра(ДокОбъект.ПериодОтчета.ДатаНачала, "Oracle"));
	ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&ДатаКон", ИнтеграцияСВнешнимиСистемамиУХ.АСЦ1_асцПолучитьТекстПараметра(КонецДня(ДокОбъект.ПериодОтчета.ДатаОкончания), "Oracle"));
	
	Свойство = ПланыВидовХарактеристик.ДополнительныеРеквизитыИСведения.НайтиПоРеквизиту("Имя", "НаименованиеUNICUS");
	Организация = УправлениеСвойствами.ЗначениеСвойства(ДокОбъект.Организация, Свойство);
	Если НЕ ЗначениеЗаполнено(Организация) Тогда
		Организация = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(ДокОбъект.Организация, "Наименование");
	КонецЕсли;	
	
	ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&Организация", "'" + Организация + "'");
	
	СтруктураЗапроса      = ПолучитьСтруктуруЗапроса(ДокОбъект);
	ТипыКолонокРезультата = ПолучитьТипыКолонокРезультата();
	ДополнительныеСвойстваИмпорта = Неопределено;
	
	ТаблицаДанных = ИнтеграцияСВнешнимиСистемамиУХ.АСЦ_ADO_ПолучитьДанныеИзЗапроса(ТекстЗапроса, СтруктураЗапроса, ТипыКолонокРезультата, ДополнительныеСвойстваИмпорта);
	
	// Можно заполнять через внутренний механизм трансформации данных,
	// но в нем нельзя делать вариативность поиска
	//ПравилаИспользованияПолей = ПолучитьПравилаИспользованияПолей(ДокОбъект.ИспользуемаяИБ.ТипБД);
	//Результат = ИнтеграцияСВнешнимиСистемамиУХ.ТрансформироватьВнешниеДанные(ДокОбъект, ТаблицаДанных, ПравилаИспользованияПолей);
	Результат = ЗаполнитьАналитику(ТаблицаДанных);
	
	Колонки = Новый Массив;
	Колонки.Добавить("FULL_PREMIUM");
	Колонки.Добавить("PREMIUM_SUM");
	Колонки.Добавить("KV_RUB");
	//Колонки.Добавить("PAY_DATE");
	//Колонки.Добавить("Пролонгация");
	//Колонки.Добавить("TS_NEW");
	
	Для каждого СтрокаТЗ из Результат Цикл
		
		Для каждого Колонка из Колонки Цикл
			
			Значение = СтрокаТЗ[Колонка];
			
			Если ВРег(СтрокаТЗ.PRODUCT_NAME) = "КАСКО" Тогда
				
				Если СтрокаТЗ.Пролонгация = 1 Тогда
					Код = "КАСКО_Пролонгация_" + Колонка;
					
				ИначеЕсли СтрокаТЗ.TS_NEW = 0 Тогда	
					Код = "КАСКО_БУ_" + Колонка;
					
				Иначе
					Код = "КАСКО_Розница_" + Колонка;
				КонецЕсли;	
				
			ИначеЕсли НРег(СтрокаТЗ.PRODUCT_NAME) = "гражданская ответственность" Тогда
				
				Если СтрокаТЗ.Пролонгация = 1 Тогда
					Код = "ГрОтв_Пролонгация_" + Колонка;
					
				ИначеЕсли СтрокаТЗ.TS_NEW = 0 Тогда	
					Код = "ГрОтв_БУ_" + Колонка;
					
				Иначе
					Код = "ГрОтв_Розница_" + Колонка;
				КонецЕсли;	
				
			ИначеЕсли ВРег(СтрокаТЗ.PRODUCT_NAME) = "ОСАГО" Тогда
				
				Если СтрокаТЗ.Пролонгация = 1 Тогда
					Код = "ОСАГО_Пролонгация_" + Колонка;
					
				ИначеЕсли СтрокаТЗ.TS_NEW = 0 Тогда	
					Код = "ОСАГО_БУ_" + Колонка;
					
				Иначе
					Код = "ОСАГО_Розница_" + Колонка;
				КонецЕсли;	
				
			ИначеЕсли НРег(СтрокаТЗ.PRODUCT_NAME) = "страхование жизни"
				ИЛИ НРег(СтрокаТЗ.PRODUCT_NAME) = "защита автокредита" Тогда
				
				Код = "СтрахованиеЖизни_" + Колонка;
			
			ИначеЕсли НРег(СтрокаТЗ.PRODUCT_NAME) = "gap страхование" Тогда
				Код = "GAP_" + Колонка;
				
			Иначе
				Код = "Прочие_" + Колонка;
			КонецЕсли;	
			
			ДокОбъект.УстановитьЗначениеПоказателя(Код, Значение, 
										СтрокаТЗ.Аналитика1, СтрокаТЗ.Аналитика2, СтрокаТЗ.Аналитика3, Неопределено);
		КонецЦикла;	
		
	КонецЦикла;	
	
КонецПроцедуры	

Функция ПолучитьПравилаИспользованияПолей(ТипБД) Экспорт
	
	ПравилаИспользованияПолей = Новый ТаблицаЗначений;
	ПравилаИспользованияПолей.Колонки.Добавить("АналитикаОперанда");
	ПравилаИспользованияПолей.Колонки.Добавить("ИндексАналитики");
	ПравилаИспользованияПолей.Колонки.Добавить("КодАналитики");
	ПравилаИспользованияПолей.Колонки.Добавить("СоздаватьНовые");
	ПравилаИспользованияПолей.Колонки.Добавить("ТаблицаАналитики");
	ПравилаИспользованияПолей.Колонки.Добавить("РеквизитАналитики");
	ПравилаИспользованияПолей.Колонки.Добавить("НеИспользоватьДляСинхронизации", Новый ОписаниеТипов("Булево"));
	ПравилаИспользованияПолей.Колонки.Добавить("РазделятьПоОрганизациям",        Новый ОписаниеТипов("Булево"));
	ПравилаИспользованияПолей.Колонки.Добавить("УровеньВложенности");
	ПравилаИспользованияПолей.Колонки.Добавить("Синоним");
	ПравилаИспользованияПолей.Колонки.Добавить("НастройкаСоответствия");
	ПравилаИспользованияПолей.Колонки.Добавить("Поле");
	ПравилаИспользованияПолей.Колонки.Добавить("ТаблицаАналитикиВИБ");
	ПравилаИспользованияПолей.Колонки.Добавить("НастройкаСоответствияРеквизит");
	ПравилаИспользованияПолей.Колонки.Добавить("ИспользованиеКонсолидация");
	ПравилаИспользованияПолей.Колонки.Добавить("СпособЗаполнения");
	ПравилаИспользованияПолей.Колонки.Добавить("ФиксированноеЗначение");
	ПравилаИспользованияПолей.Колонки.Добавить("ОбновлятьРеквизитыПриИмпорте", Новый ОписаниеТипов("Булево"));
	
	НастройкаСоответствия = ПолучитьНастройкуСоотвествия(ТипБД);
	
	// Аналитика 1: Номенклатура
	Субконто = ПланыВидовХарактеристик.ВидыСубконтоКорпоративные.СправочникНоменклатура;
	
	НоваяСтрока = ПравилаИспользованияПолей.Добавить();
	НоваяСтрока.АналитикаОперанда  = Субконто;
	НоваяСтрока.ИндексАналитики    = 1;
	НоваяСтрока.КодАналитики       = "Аналитика1";
	НоваяСтрока.СоздаватьНовые     = Ложь;
	НоваяСтрока.ТаблицаАналитики   = "Справочник.Номенклатура";
	НоваяСтрока.РеквизитАналитики  = "Наименование";
	НоваяСтрока.Синоним            = "PRODUCT_NAME";
	НоваяСтрока.УровеньВложенности = 1;
	НоваяСтрока.НастройкаСоответствия = НастройкаСоответствия;
	НоваяСтрока.НеИспользоватьДляСинхронизации = Ложь;
	
	// Аналитика 2: Контрагенты
	Субконто = ПланыВидовХарактеристик.ВидыСубконтоКорпоративные.СправочникКонтрагенты;
	
	НоваяСтрока = ПравилаИспользованияПолей.Добавить();
	НоваяСтрока.АналитикаОперанда  = Субконто;
	НоваяСтрока.ИндексАналитики    = 2;
	НоваяСтрока.КодАналитики       = "Аналитика2";
	НоваяСтрока.СоздаватьНовые     = Ложь;
	НоваяСтрока.ТаблицаАналитики   = "Справочник.Контрагенты";
	НоваяСтрока.РеквизитАналитики  = "Наименование";
	НоваяСтрока.Синоним            = "SUBJECT_NAME";
	НоваяСтрока.УровеньВложенности = 1;
	НоваяСтрока.НастройкаСоответствия = НастройкаСоответствия;
	НоваяСтрока.НеИспользоватьДляСинхронизации = Ложь;
	
	НоваяСтрока = ПравилаИспользованияПолей.Добавить();
	НоваяСтрока.АналитикаОперанда  = Субконто;
	НоваяСтрока.ИндексАналитики    = 2;
	НоваяСтрока.КодАналитики       = "Аналитика2vzvЮридическоеФизическоеЛицо";
	НоваяСтрока.ТаблицаАналитики   = "Перечисление.ЮридическоеФизическоеЛицо";
	НоваяСтрока.Синоним            = "ЮрФизЛицо";
	НоваяСтрока.РеквизитАналитики  = "ЮридическоеФизическоеЛицо.EnumRefValue";
	НоваяСтрока.НеИспользоватьДляСинхронизации = Истина;
	НоваяСтрока.НастройкаСоответствия = НастройкаСоответствия;
	НоваяСтрока.НастройкаСоответствияРеквизит  = НастройкаСоответствия;
	НоваяСтрока.УровеньВложенности = 2;
	
	НоваяСтрока = ПравилаИспользованияПолей.Добавить();
	НоваяСтрока.АналитикаОперанда  = Субконто;
	НоваяСтрока.ИндексАналитики    = 2;
	НоваяСтрока.КодАналитики       = "Аналитика2vzvСтранаРегистрации";
	НоваяСтрока.ТаблицаАналитики   = "Справочник.СтраныМира";
	НоваяСтрока.Синоним            = "ВалютаКод";
	НоваяСтрока.РеквизитАналитики  = "СтранаРегистрации.Код";
	НоваяСтрока.НеИспользоватьДляСинхронизации = Ложь;
	НоваяСтрока.НастройкаСоответствия = НастройкаСоответствия;
	НоваяСтрока.НастройкаСоответствияРеквизит  = НастройкаСоответствия;
	НоваяСтрока.УровеньВложенности = 2;
	
	// Аналитика 3: Договоры
	Субконто = ПланыВидовХарактеристик.ВидыСубконтоКорпоративные.СправочникДоговораКонтрагентов;
	
	СоотвествиеПолей = Новый Соответствие;
	СоотвествиеПолей.Вставить("Наименование", "POLICY_NUMBER");
	СоотвествиеПолей.Вставить("Номер",        "POLICY_NUMBER");
	СоотвествиеПолей.Вставить("Дата",         "DATE_SIGN");
	СоотвествиеПолей.Вставить("ДатаНачала",   "ACTION_BEGIN_DATE");
	СоотвествиеПолей.Вставить("СрокДействия", "ACTION_END_DATE");
	
	Для каждого КлючИЗначение из СоотвествиеПолей Цикл
		
		НоваяСтрока = ПравилаИспользованияПолей.Добавить();
		НоваяСтрока.АналитикаОперанда  = Субконто;
		НоваяСтрока.ИндексАналитики    = 3;
		НоваяСтрока.КодАналитики       = "Аналитика3";
		НоваяСтрока.СоздаватьНовые     = Ложь;
		НоваяСтрока.ТаблицаАналитики   = "Справочник.ДоговорыКонтрагентов";
		НоваяСтрока.РеквизитАналитики  = КлючИЗначение.Ключ;
		НоваяСтрока.Синоним            = КлючИЗначение.Значение;
		НоваяСтрока.УровеньВложенности = 1;
		НоваяСтрока.НастройкаСоответствия = НастройкаСоответствия;
		
		Если КлючИЗначение.Ключ = "Наименование" Тогда
			НоваяСтрока.НеИспользоватьДляСинхронизации = Ложь;
		Иначе	
			НоваяСтрока.НеИспользоватьДляСинхронизации = Истина;
		КонецЕсли	
		
	КонецЦикла;	
	
	НоваяСтрока = ПравилаИспользованияПолей.Добавить();
	НоваяСтрока.АналитикаОперанда  = Субконто;
	НоваяСтрока.ИндексАналитики    = 3;
	НоваяСтрока.КодАналитики       = "Аналитика3vzvВидДоговора";
	НоваяСтрока.ТаблицаАналитики   = "Перечисление.ВидыДоговоровКонтрагентов";
	НоваяСтрока.Синоним            = "ВидДоговора";
	НоваяСтрока.РеквизитАналитики  = "ВидДоговора.EnumRefValue";
	НоваяСтрока.НеИспользоватьДляСинхронизации = Истина;
	НоваяСтрока.НастройкаСоответствия = НастройкаСоответствия;
	НоваяСтрока.НастройкаСоответствияРеквизит  = НастройкаСоответствия;
	НоваяСтрока.УровеньВложенности = 2;
	
	НоваяСтрока = ПравилаИспользованияПолей.Добавить();
	НоваяСтрока.АналитикаОперанда  = Субконто;
	НоваяСтрока.ИндексАналитики    = 3;
	НоваяСтрока.КодАналитики       = "Аналитика3vzvВидДоговораУХ";
	НоваяСтрока.ТаблицаАналитики   = "Перечисление.ВидыДоговоровКонтрагентовУХ";
	НоваяСтрока.Синоним            = "ВидДоговора";
	НоваяСтрока.РеквизитАналитики  = "ВидДоговораУХ.EnumRefValue";
	НоваяСтрока.НеИспользоватьДляСинхронизации = Истина;
	НоваяСтрока.НастройкаСоответствия = НастройкаСоответствия;
	НоваяСтрока.НастройкаСоответствияРеквизит  = НастройкаСоответствия;
	НоваяСтрока.УровеньВложенности = 2;
	
	НоваяСтрока = ПравилаИспользованияПолей.Добавить();
	НоваяСтрока.АналитикаОперанда  = Субконто;
	НоваяСтрока.ИндексАналитики    = 3;
	НоваяСтрока.КодАналитики       = "Аналитика3vzvВалютаВзаиморасчетов";
	НоваяСтрока.ТаблицаАналитики   = "Справочник.Валюты";
	НоваяСтрока.Синоним            = "ВалютаКод";
	НоваяСтрока.РеквизитАналитики  = "ВалютаВзаиморасчетов.Код";
	НоваяСтрока.НеИспользоватьДляСинхронизации = Ложь;
	НоваяСтрока.НастройкаСоответствия = НастройкаСоответствия;
	НоваяСтрока.НастройкаСоответствияРеквизит  = НастройкаСоответствия;
	НоваяСтрока.УровеньВложенности = 2;
	
	НоваяСтрока = ПравилаИспользованияПолей.Добавить();
	НоваяСтрока.АналитикаОперанда  = Субконто;
	НоваяСтрока.ИндексАналитики    = 3;
	НоваяСтрока.КодАналитики       = "Аналитика3vzvВладелец";
	НоваяСтрока.ТаблицаАналитики   = "Справочник.Контрагенты";
	НоваяСтрока.Синоним            = "SUBJECT_NAME";
	НоваяСтрока.РеквизитАналитики  = "Владелец.Наименование";
	НоваяСтрока.НеИспользоватьДляСинхронизации = Ложь;
	НоваяСтрока.НастройкаСоответствия = НастройкаСоответствия;
	НоваяСтрока.НастройкаСоответствияРеквизит  = НастройкаСоответствия;
	НоваяСтрока.УровеньВложенности = 2;
	
	// Аналитика 4: Контрагенты (Страховая)
	Субконто = ПланыВидовХарактеристик.ВидыСубконтоКорпоративные.СправочникКонтрагенты;
	
	НоваяСтрока = ПравилаИспользованияПолей.Добавить();
	НоваяСтрока.АналитикаОперанда  = Субконто;
	НоваяСтрока.ИндексАналитики    = 4;
	НоваяСтрока.КодАналитики       = "Аналитика4";
	НоваяСтрока.СоздаватьНовые     = Ложь;
	НоваяСтрока.ТаблицаАналитики   = "Справочник.Контрагенты";
	НоваяСтрока.РеквизитАналитики  = "Наименование";
	НоваяСтрока.Синоним            = "SK_NAME";
	НоваяСтрока.УровеньВложенности = 1;
	НоваяСтрока.НастройкаСоответствия = НастройкаСоответствия;
	НоваяСтрока.НеИспользоватьДляСинхронизации = Ложь;
	
	НоваяСтрока = ПравилаИспользованияПолей.Добавить();
	НоваяСтрока.АналитикаОперанда  = Субконто;
	НоваяСтрока.ИндексАналитики    = 4;
	НоваяСтрока.КодАналитики       = "Аналитика4vzvЮридическоеФизическоеЛицо";
	НоваяСтрока.ТаблицаАналитики   = "Перечисление.ЮридическоеФизическоеЛицо";
	НоваяСтрока.Синоним            = "СК_ЮрФизЛицо";
	НоваяСтрока.РеквизитАналитики  = "ЮридическоеФизическоеЛицо.EnumRefValue";
	НоваяСтрока.НеИспользоватьДляСинхронизации = Истина;
	НоваяСтрока.НастройкаСоответствия = НастройкаСоответствия;
	НоваяСтрока.НастройкаСоответствияРеквизит  = НастройкаСоответствия;
	НоваяСтрока.УровеньВложенности = 2;
	
	Возврат ПравилаИспользованияПолей;
	
КонецФункции

Функция ЗаполнитьАналитику(Таблица)
	
	Результат = Таблица.Скопировать();
	
	Результат.Колонки.Добавить("Аналитика1");
	Результат.Колонки.Добавить("Аналитика2");
	Результат.Колонки.Добавить("Аналитика3");
	
	Для каждого СтрокаТЗ из Результат Цикл
		
		СтрокаТЗ.Аналитика1 = ПолучитьКонтрагента(СтрокаТЗ.SUBJECT_NAME);
		СтрокаТЗ.Аналитика2 = ПолучитьДоговор(СтрокаТЗ.Аналитика1, СтрокаТЗ);
		СтрокаТЗ.Аналитика3 = ПолучитьНоменклатуру(СтрокаТЗ.PRODUCT_NAME);
		
	КонецЦикла;	
	
	Возврат Результат;
	
КонецФункции	

Функция ПолучитьНоменклатуру(Наименование)
	
	Запрос = Новый Запрос;
	Запрос.Параметры.Вставить("Наименование", Наименование);
	
	Запрос.Текст =
	"ВЫБРАТЬ
	|	Спр.Ссылка
	|ИЗ
	|	Справочник.Номенклатура КАК Спр
	|ГДЕ
	|	НЕ Спр.ЭтоГруппа
	|	И Спр.Наименование = &Наименование";
	
	Результат = Запрос.Выполнить();
	Если НЕ Результат.Пустой() Тогда
		Возврат Результат.Выгрузить()[0][0];
	Иначе
		
		СпрОбъект = Справочники.Номенклатура.СоздатьЭлемент();
		СпрОбъект.Наименование =  Наименование;
		СпрОбъект.Записать();
		
		Возврат СпрОбъект.Ссылка;
		
	КонецЕсли;	
	
КонецФункции

Функция ПолучитьКонтрагента(Наименование)
	
	СпрСсылка = АСЦ_ОбщийМодуль.НайтиКонтрагента(Наименование, "", "");
	Если ЗначениеЗаполнено(СпрСсылка) Тогда
		
		Возврат СпрСсылка;
		
	Иначе	
		
		СпрОбъект = Справочники.Контрагенты.СоздатьЭлемент();
		СпрОбъект.Наименование =  Наименование;
		СпрОбъект.ЮридическоеФизическоеЛицо = Перечисления.ЮридическоеФизическоеЛицо.ФизическоеЛицо;
		СпрОбъект.СтранаРегистрации         = Справочники.СтраныМира.Россия;
		СпрОбъект.Записать();
		
		Возврат СпрОбъект.Ссылка;
		
	КонецЕсли;	
	
КонецФункции

Функция ПолучитьДоговор(Контрагент, Параметры)
	
	Запрос = Новый Запрос;
	Запрос.Параметры.Вставить("Наименование", Параметры.POLICY_NUMBER);
	Запрос.Параметры.Вставить("Контрагент",   Контрагент);
	
	Запрос.Текст =
	"ВЫБРАТЬ
	|	Спр.Ссылка
	|ИЗ
	|	Справочник.ДоговорыКонтрагентов КАК Спр
	|ГДЕ
	|	Спр.Наименование = &Наименование
	|	И Спр.Владелец = &Контрагент";
	
	Результат = Запрос.Выполнить();
	Если НЕ Результат.Пустой() Тогда
		Возврат Результат.Выгрузить()[0][0];
	Иначе
		
		СпрОбъект = Справочники.ДоговорыКонтрагентов.СоздатьЭлемент();
		СпрОбъект.Владелец      = Контрагент;
		СпрОбъект.Наименование  = Параметры.POLICY_NUMBER;
		СпрОбъект.Номер         = СпрОбъект.Наименование;
		СпрОбъект.ВалютаВзаиморасчетов = Константы.ВалютаРегламентированногоУчета.Получить();
		СпрОбъект.ВидДоговора   = Перечисления.ВидыДоговоровКонтрагентов.СПокупателем;
		СпрОбъект.ВидДоговораУХ = Перечисления.ВидыДоговоровКонтрагентов.СПокупателем;
		СпрОбъект.ВидСоглашения = Перечисления.ВидыСоглашений.ДоговорСУсловием;
		СпрОбъект.Дата          = Параметры.DATE_SIGN;
		СпрОбъект.ДатаНачала    = Параметры.ACTION_BEGIN_DATE;
		СпрОбъект.СрокДействия  = Параметры.ACTION_END_DATE;
		СпрОбъект.Записать();
		
		Возврат СпрОбъект.Ссылка;
		
	КонецЕсли;	
	
КонецФункции


Функция ПолучитьСтруктуруЗапроса(ДокОбъект) Экспорт
	
	СтрЗапрос = Новый Структура;
	СтрЗапрос.Вставить("СпособПолучения",  Перечисления.СпособыПолученияОперандов.ВнешниеДанныеADO);
	СтрЗапрос.Вставить("СтруктураЗапроса", Новый Структура);
	СтрЗапрос.Вставить("ТекстЗапроса",     "");
	СтрЗапрос.Вставить("ПравилаВычисленияПараметров", Новый ТаблицаЗначений);
	СтрЗапрос.Вставить("ПланСчетов",       Неопределено);
	
	СтруктураЗапроса = ИнтеграцияСВнешнимиСистемамиУХ.ПодготовитьСтруктуруЗапроса(ДокОбъект, СтрЗапрос);
	
	СтруктураРесурсов = Новый Структура;
	СтруктураЗапроса.Вставить("СтруктураРесурсов", СтруктураРесурсов);
	
	Возврат СтруктураЗапроса;
	
КонецФункции	

Функция ПолучитьТипыКолонокРезультата() Экспорт
	
	ТипыКолонокРезультата = Новый Соответствие;
	ТипыКолонокРезультата.Вставить("FULL_PREMIUM",      Тип("Число"));
	ТипыКолонокРезультата.Вставить("PREMIUM_SUM",       Тип("Число"));
	ТипыКолонокРезультата.Вставить("KV_RUB",            Тип("Число"));
	ТипыКолонокРезультата.Вставить("PAY_DATE",          Тип("Дата"));
	
	ТипыКолонокРезультата.Вставить("PRODUCT_NAME",      Тип("Строка"));
	
	ТипыКолонокРезультата.Вставить("SUBJECT_NAME",      Тип("Строка"));
	
	ТипыКолонокРезультата.Вставить("POLICY_NUMBER",     Тип("Строка"));
	ТипыКолонокРезультата.Вставить("DATE_SIGN",         Тип("Дата"));
	ТипыКолонокРезультата.Вставить("ACTION_BEGIN_DATE", Тип("Дата"));
	ТипыКолонокРезультата.Вставить("ACTION_END_DATE",   Тип("Дата"));
	
	Возврат ТипыКолонокРезультата;
	
КонецФункции	
	
Функция ПолучитьНастройкуСоотвествия(ТипБД) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Параметры.Вставить("ТипБД",    ТипБД);
	Запрос.Текст =
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	Спр.Ссылка КАК Ссылка
	|ИЗ
	|	Справочник.СоответствиеВнешнимИБ КАК Спр
	|ГДЕ
	|	Спр.ОписаниеОбъектаВИБ.Владелец = &ТипБД";
	
	Результат = Запрос.Выполнить();
	Если Результат.Пустой() Тогда
		Возврат Справочники.СоответствиеВнешнимИБ.ПустаяСсылка();
	Иначе	
		Возврат Результат.Выгрузить()[0][0];
	КонецЕсли;
	
КонецФункции

