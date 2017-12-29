﻿
Функция СведенияОВнешнейОбработке() Экспорт

	ПараметрыРегистрации = ДополнительныеОтчетыИОбработки.СведенияОВнешнейОбработке("2.1.3.1");
	
	ПараметрыРегистрации.Вид = ДополнительныеОтчетыИОбработкиКлиентСервер.ВидОбработкиДополнительнаяОбработка();
	ПараметрыРегистрации.Версия = Метаданные().Комментарий;
	ПараметрыРегистрации.БезопасныйРежим = Ложь;
	ПараметрыРегистрации.Информация      = "Формирование документов по данным экземпляра отчета UNICUS";
	
	НоваяКоманда = ПараметрыРегистрации.Команды.Добавить();
	НоваяКоманда.Представление = Метаданные().Представление();
	НоваяКоманда.Идентификатор = Метаданные().Имя;
	НоваяКоманда.Использование = ДополнительныеОтчетыИОбработкиКлиентСервер.ТипКомандыОткрытиеФормы();
	НоваяКоманда.ПоказыватьОповещение = Ложь;

	Возврат ПараметрыРегистрации;

КонецФункции

Функция ПолучитьЭкземплярыОтчетов(Период, Организация, ВидОтчета)
	
	Запрос = Новый ПостроительЗапроса;
	Запрос.Параметры.Вставить("ВидОтчета",   ВидОтчета);
	Запрос.Параметры.Вставить("Период",      Период);
	Запрос.Текст =
	"ВЫБРАТЬ
	|	Док.Ссылка КАК Ссылка
	|ИЗ
	|	Документ.НастраиваемыйОтчет КАК Док
	|ГДЕ
	|	Док.ВидОтчета = &ВидОтчета
	|	И Док.ПериодОтчета = &Период
	|	И НЕ Док.ПометкаУдаления
	|{ГДЕ
	|	Док.Организация.*}";
	
	Если ЗначениеЗаполнено(Организация) Тогда
		
		ЭлементОтбора = Запрос.Отбор.Добавить("Организация");
		ЭлементОтбора.Установить(Организация, Истина);
		
	КонецЕсли;	
	
	Запрос.Выполнить();
	Возврат Запрос.Результат.Выгрузить().ВыгрузитьКолонку("Ссылка");
	
КонецФункции	

Функция ЗначенияОтличаются(Структруа1, Структура2)
	
	Для каждого КлючИЗначение Из Структруа1 Цикл
		
		Если КлючИЗначение.Значение <> Структура2[КлючИЗначение.Ключ] Тогда
			Возврат Истина;
		КонецЕсли;
		
	КонецЦикла;	
	
	Возврат Ложь;
	
КонецФункции	

Процедура ЗаписатьДокумент(ДокОбъект)
	
	Если ДокОбъект = Неопределено Тогда
		Возврат;
	КонецЕсли;	
	
	Если ДокОбъект.Проведен Тогда
		Режим = РежимЗаписиДокумента.Проведение;
	Иначе
		Режим = РежимЗаписиДокумента.Запись;
	КонецЕсли;	
	
	Попытка
		ДокОбъект.Записать(Режим);
	Исключение
		ОписаниеОшибки = ОписаниеОшибки();
		Сообщить(ОписаниеОшибки);
		ЗаписьЖурналаРегистрации("Загрузка отчета UNICUS",
			УровеньЖурналаРегистрации.Ошибка, ДокОбъект.Метаданные(), ДокОбъект.Ссылка, ОписаниеОшибки);
	КонецПопытки;	
	
КонецПроцедуры	

// В УПП: Загрузка полисов В УПП с ИНН и КПП
// доп. документ АСЦ_НачислениеПремии_СБ
// В таблице есть 2 даты: дата подписания (дата договора, DATE_SIGN) и дата оплаты (PAY_DATE)
// Дата документа - это дата договора
#Область Contracts

Процедура ЗагрузитьContracts(Параметры, АдресРезультата) Экспорт
	
	ВидОтчета = Справочники.ВидыОтчетов.НайтиПоКоду("UNICUS_Contracts");
	МассивЭкзОтчетов = ПолучитьЭкземплярыОтчетов(Параметры.Период, Параметры.Организация, ВидОтчета);
	СформироватьДокументыРТУ(МассивЭкзОтчетов, Параметры.ПерезаполнятьДокументы);
	
КонецПроцедуры	

Функция ПолучитьТаблицуПоказателейContracts(ДокументСсылка)
	
	Запрос = Новый Запрос;
	Запрос.Параметры.Вставить("ЭкземплярОтчета", ДокументСсылка);
	Запрос.Параметры.Вставить("Показатель1",     "KV_RUB");
	Запрос.Параметры.Вставить("Показатель2",     "PAY_DATE");
	
	Запрос.Текст =
	"ВЫБРАТЬ
	|	Выборка.Номенклатура КАК Номенклатура,
	|	Выборка.Контрагент КАК Контрагент,
	|	Выборка.Договор КАК Договор,
	|	МАКСИМУМ(Выборка.KV_Rub) КАК Сумма,
	|	МАКСИМУМ(Выборка.Pay_Date) КАК Дата
	|ИЗ
	|	(ВЫБРАТЬ
	|		Рег.Аналитика1 КАК Контрагент,
	|		Рег.Аналитика2 КАК Договор,
	|		Рег.Аналитика3 КАК Номенклатура,
	|		Рег.Значение КАК KV_Rub,
	|		NULL КАК Pay_Date
	|	ИЗ
	|		РегистрСведений.ЗначенияПоказателейОтчетов3 КАК Рег
	|	ГДЕ
	|		Рег.Версия.ЭкземплярОтчета В(&ЭкземплярОтчета)
	|		И Рег.Показатель.Колонка.Код = &Показатель1
	|		И Рег.ИтоговоеЗначение = ЛОЖЬ
	|	
	|	ОБЪЕДИНИТЬ ВСЕ
	|	
	|	ВЫБРАТЬ
	|		Рег.Аналитика1,
	|		Рег.Аналитика2,
	|		Рег.Аналитика3,
	|		NULL,
	|		Рег.Значение
	|	ИЗ
	|		РегистрСведений.ЗначенияПоказателейОтчетовНечисловые КАК Рег
	|	ГДЕ
	|		Рег.Версия.ЭкземплярОтчета В(&ЭкземплярОтчета)
	|		И Рег.Показатель.Колонка.Код = &Показатель2
	|		И Рег.ИтоговоеЗначение = ЛОЖЬ) КАК Выборка
	|
	|СГРУППИРОВАТЬ ПО
	|	Выборка.Номенклатура,
	|	Выборка.Контрагент,
	|	Выборка.Договор
	|
	|УПОРЯДОЧИТЬ ПО
	|	Контрагент
	|АВТОУПОРЯДОЧИВАНИЕ";
	
	Таблица = Запрос.Выполнить().Выгрузить();
	Возврат Таблица;
	
КонецФункции	

Функция СформироватьДокументыРТУ(МассивЭкзОтчетов, ПерезаполнятьДокументы)
	
	Для каждого ДокументСсылка из МассивЭкзОтчетов Цикл
		
		ТаблицаДанных = ПолучитьТаблицуПоказателейContracts(ДокументСсылка);
		
		Организация = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(ДокументСсылка, "Организация");
		
		Всего   = ТаблицаДанных.Количество();
		Счетчик = 0;
		
		Для каждого СтрокаТЗ из ТаблицаДанных Цикл
			
			СоздатьДокументРТУ(Организация, СтрокаТЗ, ПерезаполнятьДокументы);
			
			Счетчик = Счетчик + 1;
			ПроцентВыполнения = Окр(100 * Счетчик / Всего, 2);
			ДлительныеОперации.СообщитьПрогресс(ПроцентВыполнения, "" + Организация + ": " + Счетчик + " из " + Всего);
			
		КонецЦикла;	
		
	КонецЦикла;	
	
КонецФункции	

Функция СоздатьДокументРТУ(Организация, Параметры, ПерезаполнятьДокументы)
	
	ДатаДок = Параметры.Договор.Дата;
	
	Запрос = Новый Запрос;
	Запрос.Параметры.Вставить("Договор", Параметры.Договор);
	Запрос.Параметры.Вставить("Дата1",   ДатаДок);
	Запрос.Параметры.Вставить("Дата2",   КонецДня(ДатаДок));
	
	Запрос.Текст =
	"ВЫБРАТЬ
	|	Док.Ссылка КАК Ссылка
	|ИЗ
	|	Документ.РеализацияТоваровУслуг КАК Док
	|ГДЕ
	|	Док.ДоговорКонтрагента = &Договор
	|	И НЕ Док.ПометкаУдаления
	|	И Док.Дата МЕЖДУ &Дата1 И &Дата2";
	
	Результат = Запрос.Выполнить();
	Если НЕ Результат.Пустой() Тогда
		
		ДокументСсылка = Результат.Выгрузить()[0][0];
		
		Если ПерезаполнятьДокументы = Истина Тогда
			ДокументОбъект = ДокументСсылка.ПолучитьОбъект();
			ДокументОбъект.Проведен = Ложь;
		Иначе
			Возврат ДокументСсылка;
		КонецЕсли;
		
	Иначе
		ДокументОбъект = Документы.РеализацияТоваровУслуг.СоздатьДокумент();
	КонецЕсли;	
	
	ДокументОбъект.Организация = Организация;
	ДокументОбъект.Дата        = ДатаДок;
	ДокументОбъект.Контрагент  = Параметры.Контрагент;
	ДокументОбъект.ДоговорКонтрагента = Параметры.Договор;
	
	ДокументОбъект.ВалютаДокумента = Константы.ВалютаРегламентированногоУчета.Получить();
	ДокументОбъект.ВидОперации     = Перечисления.ВидыОперацийРеализацияТоваров.Услуги;
	ДокументОбъект.СчетУчетаРасчетовСКонтрагентом = ПланыСчетов.Хозрасчетный.РасчетыСПрочимиПоставщикамиИПодрядчиками;
	ДокументОбъект.СчетУчетаРасчетовПоАвансам     = ПланыСчетов.Хозрасчетный.РасчетыСПрочимиПоставщикамиИПодрядчиками;
	ДокументОбъект.СпособЗачетаАвансов = Перечисления.СпособыЗачетаАвансов.Автоматически;
	
	ДокументОбъект.Услуги.Очистить();
	
	ПараметрыОбъекта = Новый Структура;
	ПараметрыОбъекта.Вставить("Дата",        Параметры.Дата);
	ПараметрыОбъекта.Вставить("Организация", Организация);
	
	СведенияОНоменклатуре = БухгалтерскийУчетПереопределяемый.ПолучитьСведенияОНоменклатуре(Параметры.Номенклатура, ПараметрыОбъекта);
	
	НоваяСтрока = ДокументОбъект.Услуги.Добавить();
	НоваяСтрока.Номенклатура = Параметры.Номенклатура;
	НоваяСтрока.Содержание   = СведенияОНоменклатуре.НаименованиеПолное;
	НоваяСтрока.Сумма        = Параметры.Сумма;
	НоваяСтрока.СтавкаНДС    = Перечисления.СтавкиНДС.БезНДС;
	НоваяСтрока.СчетДоходов  = СведенияОНоменклатуре.СчетаУчета.СчетДоходов;
	НоваяСтрока.СчетРасходов = СведенияОНоменклатуре.СчетаУчета.СчетРасходов;
	НоваяСтрока.СчетУчетаНДСПоРеализации = СведенияОНоменклатуре.СчетаУчета.СчетУчетаНДСПродажи;
	НоваяСтрока.Субконто     = СведенияОНоменклатуре.НоменклатурнаяГруппа;
	
	Если НЕ ЗначениеЗаполнено(НоваяСтрока.СчетРасходов) Тогда
		НоваяСтрока.СчетРасходов = ПланыСчетов.Хозрасчетный.СебестоимостьПродажНеЕНВД; //90.02.1
	КонецЕсли;	
	
	Если НЕ ЗначениеЗаполнено(НоваяСтрока.СчетДоходов) Тогда
		НоваяСтрока.СчетДоходов = ПланыСчетов.Хозрасчетный.ВыручкаНеЕНВД; //90.01.1
	КонецЕсли;	
	
	Если НЕ ЗначениеЗаполнено(НоваяСтрока.СчетУчетаНДСПоРеализации) Тогда
		НоваяСтрока.СчетУчетаНДСПоРеализации = ПланыСчетов.Хозрасчетный.Продажи_НДС; //90.03
	КонецЕсли;	
	
	ЗаписатьДокумент(ДокументОбъект);				
	
	Возврат ДокументОбъект.Ссылка;
	
КонецФункции	

#КонецОбласти

// В УПП: Загрузка отчетов посредника В УПП
// доп. документ АСЦ_НачислениеПремии_СБ
#Область Act

Процедура ЗагрузитьActs(Параметры, АдресРезультата) Экспорт
	
	ВидОтчета = Справочники.ВидыОтчетов.НайтиПоКоду("UNICUS_Acts");
	МассивЭкзОтчетов = ПолучитьЭкземплярыОтчетов(Параметры.Период, Параметры.Организация, ВидОтчета);
	СформироватьДокументыОтчетПосредника(МассивЭкзОтчетов, Параметры.ПерезаполнятьДокументы);
	
КонецПроцедуры	

Функция ПолучитьТаблицуПоказателейActs(ДокументСсылка)
	
	Запрос = Новый Запрос;
	Запрос.Параметры.Вставить("ЭкземплярОтчета", ДокументСсылка);
	Запрос.Параметры.Вставить("ПоказательКВ_руб",  "КВ_руб");
	Запрос.Параметры.Вставить("ПоказательДатаДок", "ДатаДок");
	
	Запрос.Текст =
	"ВЫБРАТЬ
	|	Выборка.Контрагент КАК Контрагент,
	|	Выборка.Договор КАК Договор,
	|	Выборка.СК КАК СК,
	|	Выборка.ДоговорСК КАК ДоговорСК,
	|	МАКСИМУМ(Выборка.КВ_руб) КАК КВ_руб,
	|	МАКСИМУМ(Выборка.ДатаДок) КАК ДатаДок
	|ИЗ
	|	(ВЫБРАТЬ
	|		Рег.Аналитика1 КАК Контрагент,
	|		Рег.Аналитика2 КАК Договор,
	|		Рег.Аналитика3 КАК СК,
	|		Рег.Аналитика4 КАК ДоговорСК,
	|		Рег.Значение КАК КВ_руб,
	|		NULL КАК ДатаДок
	|	ИЗ
	|		РегистрСведений.ЗначенияПоказателейОтчетов4 КАК Рег
	|	ГДЕ
	|		Рег.Версия.ЭкземплярОтчета В(&ЭкземплярОтчета)
	|		И Рег.Показатель.Колонка.Код = &ПоказательКВ_руб
	|		И Рег.ИтоговоеЗначение = ЛОЖЬ
	|	
	|	ОБЪЕДИНИТЬ ВСЕ
	|	
	|	ВЫБРАТЬ
	|		Рег.Аналитика1,
	|		Рег.Аналитика2,
	|		Рег.Аналитика3,
	|		Рег.Аналитика4,
	|		NULL,
	|		Рег.Значение
	|	ИЗ
	|		РегистрСведений.ЗначенияПоказателейОтчетовНечисловые КАК Рег
	|	ГДЕ
	|		Рег.Версия.ЭкземплярОтчета В(&ЭкземплярОтчета)
	|		И Рег.Показатель.Колонка.Код = &ПоказательДатаДок
	|		И Рег.ИтоговоеЗначение = ЛОЖЬ) КАК Выборка
	|
	|СГРУППИРОВАТЬ ПО
	|	Выборка.Контрагент,
	|	Выборка.Договор,
	|	Выборка.СК,
	|	Выборка.ДоговорСК
	|
	|УПОРЯДОЧИТЬ ПО
	|	ДатаДок, СК, ДоговорСК, Контрагент
	|АВТОУПОРЯДОЧИВАНИЕ";
	
	Таблица = Запрос.Выполнить().Выгрузить();
	Возврат Таблица;
	
КонецФункции	

Функция СформироватьДокументыОтчетПосредника(МассивЭкзОтчетов, ПерезаполнятьДокументы)
	
	Для каждого ДокументСсылка из МассивЭкзОтчетов Цикл
		
		ТаблицаДанных = ПолучитьТаблицуПоказателейActs(ДокументСсылка);
		
		Организация = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(ДокументСсылка, "Организация");
		
		Всего   = ТаблицаДанных.Количество();
		Счетчик = 0;
		
		ПредЗначения = Новый Структура("ДатаДок, СК, ДоговорСК");
		ДокОбъект    = Неопределено;
		
		Для каждого СтрокаТЗ из ТаблицаДанных Цикл
			
			Если ЗначенияОтличаются(ПредЗначения, СтрокаТЗ) Тогда
				ЗаписатьДокумент(ДокОбъект);				
				ДокОбъект = СоздатьДокументОтчетПосредника(Организация, СтрокаТЗ, ПерезаполнятьДокументы);
				ЗаполнитьЗначенияСвойств(ПредЗначения, СтрокаТЗ);
			КонецЕсли;	
			
			Счетчик = Счетчик + 1;
			ПроцентВыполнения = Окр(100 * Счетчик / Всего, 2);
			ДлительныеОперации.СообщитьПрогресс(ПроцентВыполнения, "" + Организация + ": " + Счетчик + " из " + Всего);
			
			// Тут заполнение таб. части
			
		КонецЦикла;	
		
		ЗаписатьДокумент(ДокОбъект);				
		
	КонецЦикла;	
	
КонецФункции	

Функция СоздатьДокументОтчетПосредника(Организация, Параметры, ПерезаполнятьДокументы)
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	Док.Ссылка КАК Ссылка
	|ИЗ
	|	Документ.АСЦ_ОтчетПосредника КАК Док
	|ГДЕ
	|	Док.Номер = &Номер";
	
КонецФункции	

#КонецОбласти

