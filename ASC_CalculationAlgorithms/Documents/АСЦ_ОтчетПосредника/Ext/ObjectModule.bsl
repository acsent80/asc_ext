﻿#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ОБЩЕГО НАЗНАЧЕНИЯ
//

Процедура ЗаписатьДокумент(ДокументОбъект)
	
	Если ДокументОбъект = Неопределено Тогда
		Возврат;
	КонецЕсли;	
	
	Если ДокументОбъект.Проведен Тогда
		Режим = РежимЗаписиДокумента.Проведение;
	Иначе
		Режим = РежимЗаписиДокумента.Запись;
	КонецЕсли;	
	
	ДокументОбъект.Записать(Режим);
	
КонецПроцедуры	

// Функция проверяет соотвествие документа и данным строки
// Ворзвращаемое занчение: 
//    Истина - Документ соотвествует строке, перезаполнять не нужно
//    Ложь   - Документ не соответствует строке
Функция ДокументРТУСоответствуетСтроке(ДокументОбъект, СтрокаТЧ)
	
	Если Ложь Тогда
		ДокументОбъект = Документы.РеализацияТоваровУслуг.СоздатьДокумент();
	КонецЕсли;	
	
	// Шапка
	Если НЕ (ДокументОбъект.Организация = Организация
		И ДокументОбъект.Контрагент  = СтрокаТЧ.Контрагент
		И ДокументОбъект.ДоговорКонтрагента = СтрокаТЧ.ДоговорКонтрагента
		И ДокументОбъект.ПодразделениеОрганизации = ПодразделениеОрганизации) Тогда
		
		Возврат Ложь;
		
	КонецЕсли;	
	
	// ТЧ услуги
	Если СтрокаТЧ.СуммаКВ <> 0 Тогда
		
		Если ДокументОбъект.Услуги.Количество() <> 1 Тогда
			Возврат Ложь;
		КонецЕсли;
		
		НоваяСтрока = ДокументОбъект.Услуги[0];
		Если НЕ (НоваяСтрока.Номенклатура = СтрокаТЧ.Номенклатура
			И НоваяСтрока.Сумма = СтрокаТЧ.СуммаКВ) Тогда
			
			Возврат Ложь;
			
		КонецЕсли;	
		
	КонецЕсли;
	
	// ТЧ агентские услуги
	Если СтрокаТЧ.СуммаОплаты - СтрокаТЧ.СуммаКВ <> 0 Тогда
		
		Если ДокументОбъект.АгентскиеУслуги.Количество() <> 1 Тогда
			Возврат Ложь;
		КонецЕсли;
		
		НоваяСтрока = ДокументОбъект.АгентскиеУслуги[0];
		Если НЕ (НоваяСтрока.Номенклатура = СтрокаТЧ.Номенклатура
			И НоваяСтрока.Сумма = СтрокаТЧ.СуммаОплаты - СтрокаТЧ.СуммаКВ
			И НоваяСтрока.Контрагент = Контрагент
			И НоваяСтрока.ДоговорКонтрагента = ДоговорКонтрагента) Тогда
			
			Возврат Ложь;
			
		КонецЕсли;	
		
	КонецЕсли;
	
	Возврат Истина;
	
КонецФункции	

Функция ЗаполнитьРТУПоСтроке(СтрокаТЧ) Экспорт
	
	СвойствоID = ПланыВидовХарактеристик.ДополнительныеРеквизитыИСведения.НайтиПоРеквизиту("Имя", "UNICUS_ID");
	ЭтоКорректировка = Ложь;
	
	ДокументСсылка = СтрокаТЧ.Документ;
	Если НЕ ЗначениеЗаполнено(ДокументСсылка) Тогда
		ДокументСсылка = АСЦ_ОбщийМодуль.НайтиДокументПоСвойству(СтрокаТЧ.ID, СвойствоID, "РеализацияТоваровУслуг");
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ДокументСсылка) Тогда
		
		ДокументКорректировки = АСЦ_ОбщийМодуль.НайтиДокументКорректировки(ДокументСсылка);
		Если ЗначениеЗаполнено(ДокументКорректировки) Тогда
			ЭтоКорректировка = Истина;
		КонецЕсли;
		
	КонецЕсли;	
	
	Если ЗначениеЗаполнено(ДокументСсылка) Тогда
		
		ДокументОбъект = ДокументСсылка.ПолучитьОбъект();
		
		Если ДокументРТУСоответствуетСтроке(ДокументОбъект, СтрокаТЧ) Тогда
			СтрокаТЧ.Документ = ДокументСсылка;
			Возврат ДокументСсылка;
		КонецЕсли;	
		
		ДокументОбъект.Товары.Очистить();
		ДокументОбъект.Услуги.Очистить();
		ДокументОбъект.АгентскиеУслуги.Очистить();
		
	Иначе
		//ДокументОбъект = Документы.РеализацияТоваровУслуг.СоздатьДокумент();
		Сообщить("Не найден документ реализации для договора " + СтрокаТЧ.ДоговорКонтрагента);
		Возврат Документы.РеализацияТоваровУслуг.ПустаяСсылка();
	КонецЕсли;	
	
	ВремяДокумента = Документы.РеализацияТоваровУслуг.ВремяДокументаПоУмолчанию();
	
	ДокументОбъект.ПометкаУдаления     = Ложь;
	ДокументОбъект.Дата                = НачалоДня(Дата) + ВремяДокумента.Часы * 3600 + ВремяДокумента.Минуты * 60;
	ДокументОбъект.Организация         = Организация;
	ДокументОбъект.Контрагент          = СтрокаТЧ.Контрагент;
	ДокументОбъект.ДоговорКонтрагента  = СтрокаТЧ.ДоговорКонтрагента;
	ДокументОбъект.ВалютаДокумента     = ОбщегоНазначенияБПВызовСервераПовтИсп.ПолучитьВалютуРегламентированногоУчета();
	ДокументОбъект.Ответственный       = Пользователи.ТекущийПользователь();
	ДокументОбъект.СпособЗачетаАвансов = Перечисления.СпособыЗачетаАвансов.Автоматически;
	ДокументОбъект.ВидОперации         = Перечисления.ВидыОперацийРеализацияТоваров.ПродажаКомиссия;
	ДокументОбъект.СчетУчетаРасчетовСКонтрагентом = ПланыСчетов.Хозрасчетный.НайтиПоКоду("76.05");
	ДокументОбъект.СчетУчетаРасчетовПоАвансам     = ПланыСчетов.Хозрасчетный.НайтиПоКоду("76.05");
	ДокументОбъект.ПодразделениеОрганизации       = ПодразделениеОрганизации;
	
	Если СтрокаТЧ.СуммаКВ <> 0 Тогда
		
		НоваяСтрока = ДокументОбъект.Услуги.Добавить();
		НоваяСтрока.Номенклатура = СтрокаТЧ.Номенклатура;
		НоваяСтрока.Сумма        = СтрокаТЧ.СуммаКВ;
		НоваяСтрока.СтавкаНДС    = Перечисления.СтавкиНДС.БезНДС;
		НоваяСтрока.СчетДоходов  = ПланыСчетов.Хозрасчетный.НайтиПоКоду("90.01.1");
		НоваяСтрока.Субконто     = НоваяСтрока.Номенклатура.НоменклатурнаяГруппа;
		
	КонецЕсли;
	
	Если СтрокаТЧ.СуммаОплаты - СтрокаТЧ.СуммаКВ <> 0 Тогда
		
		НоваяСтрока = ДокументОбъект.АгентскиеУслуги.Добавить();
		НоваяСтрока.Номенклатура = СтрокаТЧ.Номенклатура;
		НоваяСтрока.Сумма        = СтрокаТЧ.СуммаОплаты - СтрокаТЧ.СуммаКВ;
		НоваяСтрока.СтавкаНДС    = Перечисления.СтавкиНДС.БезНДС;
		НоваяСтрока.Контрагент   = Контрагент;
		НоваяСтрока.ДоговорКонтрагента = ДоговорКонтрагента;
		НоваяСтрока.СчетРасчетов = ПланыСчетов.Хозрасчетный.НайтиПоКоду("76.01.1");
		
	КонецЕсли;
	
	НачатьТранзакцию();
	
	ЗаписатьДокумент(ДокументОбъект);
	
	Запись = РегистрыСведений.ДополнительныеСведения.СоздатьМенеджерЗаписи();
	Запись.Объект   = ДокументОбъект.Ссылка;
	Запись.Свойство = ПланыВидовХарактеристик.ДополнительныеРеквизитыИСведения.НайтиПоРеквизиту("Имя", "ID_Unicus");
	Запись.Значение = ID_Unicus;
	Запись.Записать();
	
	ЗафиксироватьТранзакцию();
	
	СтрокаТЧ.Документ = ДокументОбъект.Ссылка;
	
	Возврат ДокументОбъект.Ссылка;
	
КонецФункции

Функция ЗаполнитьОтчетКомитенту() Экспорт
	
	ДокументСсылка = ОтчетКомитентуОПродажах;
	Если НЕ ЗначениеЗаполнено(ДокументСсылка) Тогда
		ДокументСсылка = АСЦ_ОбщийМодуль.НайтиДокументПоСвойству(ID_Unicus, "ОтчетКомитентуОПродажах");
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ДокументСсылка) Тогда
		
		ДокументОбъект = ДокументСсылка.ПолучитьОбъект();
		ДокументОбъект.Товары.Очистить();
		
	Иначе
		
		ДокументОбъект = Документы.ОтчетКомитентуОПродажах.СоздатьДокумент();
		
	КонецЕсли;	
	
	ДокументОбъект.ПометкаУдаления    = Ложь;

	ДокументОбъект.ВидОперации        = Перечисления.ВидыОперацийОтчетКомитентуОПродажах.ОтчетОПродажах;
	ДокументОбъект.Организация        = Организация;
	ДокументОбъект.Контрагент         = Контрагент;
	ДокументОбъект.ДоговорКонтрагента = ДоговорКонтрагента;
	ДокументОбъект.ВалютаДокумента    = ОбщегоНазначенияБПВызовСервераПовтИсп.ПолучитьВалютуРегламентированногоУчета();
	ДокументОбъект.Ответственный      = Пользователи.ТекущийПользователь();
	ДокументОбъект.ПодразделениеОрганизации = ПодразделениеОрганизации;
	ДокументОбъект.СпособРасчетаКомиссионногоВознаграждения = Перечисления.СпособыРасчетаКомиссионногоВознаграждения.НеРассчитывается;
	ДокументОбъект.СтавкаНДСВознаграждения  = Перечисления.СтавкиНДС.БезНДС;
	ДокументОбъект.СчетУчетаРасчетовСКонтрагентом = ПланыСчетов.Хозрасчетный.НайтиПоКоду("76.01.1");
	ДокументОбъект.СчетДоходов                    = ПланыСчетов.Хозрасчетный.НайтиПоКоду("76.01.1");
	
	Для каждого СтрокаТЧ из Продажи Цикл
		
		Если СтрокаТЧ.СуммаОплаты <> 0 Тогда
			
			НоваяСтрока = ДокументОбъект.Товары.Добавить();
			НоваяСтрока.Номенклатура = СтрокаТЧ.Номенклатура;
			НоваяСтрока.Покупатель   = СтрокаТЧ.Контрагент;
			НоваяСтрока.Сумма        = СтрокаТЧ.СуммаОплаты;
			НоваяСтрока.СтавкаНДС    = Перечисления.СтавкиНДС.БезНДС;
			НоваяСтрока.ДатаРеализации = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(СтрокаТЧ.Документ, "Дата");
			НоваяСтрока.КлючСтроки   = НоваяСтрока.НомерСтроки;
			
			ДокументОбъект.Дата      = Макс(ДокументОбъект.Дата, НоваяСтрока.ДатаРеализации);
			
		КонецЕсли;	
		
	КонецЦикла;	
	
	// Дата документа - максимальная дата реализации
	// дата документа в Юникус - это обычно начало месяца
	ВремяДокумента = Документы.ОтчетКомитентуОПродажах.ВремяДокументаПоУмолчанию();
	ДокументОбъект.Дата = НачалоДня(ДокументОбъект.Дата) + ВремяДокумента.Часы * 3600 + ВремяДокумента.Минуты * 60;
	
	НачатьТранзакцию();
	
	ЗаписатьДокумент(ДокументОбъект);
	
	Запись = РегистрыСведений.ДополнительныеСведения.СоздатьМенеджерЗаписи();
	Запись.Объект   = ДокументОбъект.Ссылка;
	Запись.Свойство = ПланыВидовХарактеристик.ДополнительныеРеквизитыИСведения.НайтиПоРеквизиту("Имя", "ID_Unicus");
	Запись.Значение = ID_Unicus;
	Запись.Записать();
	
	ЗафиксироватьТранзакцию();
	
	ОтчетКомитентуОПродажах = ДокументОбъект.Ссылка;
	
	Возврат ДокументОбъект.Ссылка;
	
КонецФункции	

Процедура ЗаполнитьСвязанныеДокументы() Экспорт
	
	//// Может быть несколько одинаковых договоров (оплата разными датами)
	//// Будем искать документы сразу для всех строк договора
	//
	////Используем однопроходный перебор отсортирвоанной таблицы
	//Продажи.Сортировать("Контрагент, ДоговорКонтрагента, СуммаОплаты УБЫВ");
	//
	//ПредДоговор = Неопределено;
	//Для каждого СтрокаТЧ из Продажи Цикл
	//	
	//	// Изменился Договор
	//	Если ПредДоговор <> СтрокаТЧ.ДоговорКонтрагента Тогда
	//		ПредДоговор = СтрокаТЧ.ДоговорКонтрагента;
	//		МассивСтрок = Новый Массив;
	//		ЗаполнитьРТУПоСтрокамДоговора(МассивСтрок);
	//	КонецЕсли;	
	//	
	//	МассивСтрок.Добавить(СтрокаТЧ);
	//	
	//КонецЦикла;	
	//ЗаполнитьРТУПоСтрокамДоговора(МассивСтрок);
	
	Для каждого СтрокаТЧ из Продажи Цикл
		ЗаполнитьРТУПоСтроке(СтрокаТЧ);
	КонецЦикла;	
		
	ЗаполнитьОтчетКомитенту();
	
КонецПроцедуры	

Процедура ПровестиСвязныеДокументы(РежимЗаписи = Неопределено, РежимПроведения = Неопределено) Экспорт
	
	Если РежимЗаписи = Неопределено Тогда 
		РежимЗаписи = РежимЗаписиДокумента.Проведение;
	КонецЕсли;
	
	Если РежимПроведения = Неопределено Тогда 
		РежимПроведения = РежимПроведенияДокумента.Неоперативный;
	КонецЕсли;	
	
	Для каждого СтрокаТЧ из Продажи Цикл
		
		Если НЕ ЗначениеЗаполнено(СтрокаТЧ.Документ) Тогда
			Продолжить;
		КонецЕсли;
			
		ДокументОбъект = СтрокаТЧ.Документ.ПолучитьОбъект();
		ДокументОбъект.Записать(РежимЗаписи, РежимПроведения);
		
	КонецЦикла;	
	
	ДокументОбъект = ОтчетКомитентуОПродажах.ПолучитьОбъект();
	ДокументОбъект.Записать(РежимЗаписи, РежимПроведения);
	
КонецПроцедуры	

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ - ОБРАБОТЧИКИ СОБЫТИЙ
//

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	// Если не ведется учет по договорам и заполнен договор, 
	// то по реквизитам этого договора ищем основной договор
	// Если находим, то устанавливаем основной договор в качестве договора контрагента в документе.
	// В случае если не находим, то устанавливаем договор, который выбрал пользователь, как основной. 
	Если НЕ ПолучитьФункциональнуюОпцию("ВестиУчетПоДоговорам") И ЗначениеЗаполнено(ДоговорКонтрагента) Тогда
		СтруктураРеквизитов = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(ДоговорКонтрагента, "Организация, Владелец, ВидДоговора");
		
		ОсновнойДоговор = Справочники.ДоговорыКонтрагентов.ПустаяСсылка();
		РаботаСДоговорамиКонтрагентовБП.УстановитьДоговорКонтрагента(
			ОсновнойДоговор, 
			СтруктураРеквизитов.Владелец,
			СтруктураРеквизитов.Организация,
			СтруктураРеквизитов.ВидДоговора);
			
		Если ЗначениеЗаполнено(ОсновнойДоговор) Тогда
			ДоговорКонтрагента = ОсновнойДоговор;
		Иначе
			РаботаСДоговорамиКонтрагентовБП.УстановитьОсновнойДоговорКонтрагента(ДоговорКонтрагента);
		КонецЕсли;
	КонецЕсли;

КонецПроцедуры

Процедура ОбработкаЗаполнения(ДанныеЗаполнения, СтандартнаяОбработка)

	ЗаполнениеДокументов.Заполнить(ЭтотОбъект, ДанныеЗаполнения);

КонецПроцедуры

Процедура ПриКопировании(ОбъектКопирования)

	Дата = НачалоДня(ОбщегоНазначения.ТекущаяДатаПользователя());

КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	
	ПровестиСвязныеДокументы(РежимЗаписиДокумента.Проведение, РежимПроведения);
	
КонецПроцедуры

Процедура ОбработкаУдаленияПроведения(Отказ)
	
	ПровестиСвязныеДокументы(РежимЗаписиДокумента.ОтменаПроведения);
	
КонецПроцедуры

#КонецЕсли
