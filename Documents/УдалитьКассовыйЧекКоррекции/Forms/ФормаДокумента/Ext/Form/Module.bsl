﻿
//#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)

	// Пропускаем инициализацию, чтобы гарантировать получение формы при передаче параметра "АвтоТест".
	Если Параметры.Свойство("АвтоТест") Тогда
		Возврат;
	КонецЕсли;
	
	УстановитьДоступностьЭлементовИФормы();
	
	Если Не ПустаяСтрока(Объект.Организация) Тогда
		ОбновитьСистемыНалогообложения();
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)
	
	УстановитьДоступностьЭлементовИФормы();
	
КонецПроцедуры

&НаКлиенте
Процедура ПослеЗаписи(ПараметрыЗаписи)
	
	УстановитьДоступностьЭлементовИФормы();
	
КонецПроцедуры

//#КонецОбласти

//#Область ОбработчикиСобытийЭлементовШапки

&НаСервере
Процедура ОбновитьСистемыНалогообложения();
	
	СтандартнаяОбработка = Истина;
	МассивСистемНалогообложения = Новый Массив();
	
	Для Каждого СистемаНалогообложенияККТ Из Перечисления.ТипыСистемНалогообложенияККТ Цикл
		МассивСистемНалогообложения.Добавить(СистемаНалогообложенияККТ);
	КонецЦикла;
	
	СписокВыбора = Элементы.СистемаНалогообложения.СписокВыбора;
	СписокВыбора.Очистить();
	
	Для Каждого СистемаНалогообложения Из МассивСистемНалогообложения Цикл
		СписокВыбора.Добавить(СистемаНалогообложения);
	КонецЦикла;
	
	Если МассивСистемНалогообложения.Количество() = 1 Тогда
		Объект.СистемаНалогообложения = МассивСистемНалогообложения[0];
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОрганизацияПриИзменении(Элемент)
	
	ОбновитьСистемыНалогообложения();
	
КонецПроцедуры

&НаКлиенте
Процедура ОплатаПриИзменении(Элемент)
	
	ПересчитатьДокументНаКлиенте();
	
КонецПроцедуры

//#КонецОбласти

//#Область ОбработчикиКомандФормы

// Процедура выполняет печать чека на фискальном регистраторе.
//
&НаКлиенте
Процедура НапечататьЧекКоррекции(Команда)
	
	ОчиститьСообщения();
	
	Если Объект.ПробитЧек Тогда
		ТекстСообщения = НСтр("ru = 'Чек уже пробит на фискальном устройстве.'");
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения);
		Возврат;
	КонецЕсли;
	
	Если НЕ Объект.Проведен ИЛИ Модифицированность Тогда
		
		ТекстВопроса = НСтр("ru='Операция возможна только после проведения документа, провести документ?'");
		Ответ = Вопрос(ТекстВопроса, РежимДиалогаВопрос.ДаНет);
		
		Если Ответ = КодВозвратаДиалога.Да Тогда
			Попытка
				Записать(Новый Структура("РежимЗаписи", РежимЗаписиДокумента.Проведение));
			Исключение
				Предупреждение(НСтр("ru = 'Не удалось выполнить проведение документа'"));
				Возврат;
			КонецПопытки;
		Иначе
			Возврат;
		КонецЕсли;

	КонецЕсли;
	
	МассивККТ = ПолучитьСерверТО().ПолучитьСписокУстройств(
		ПредопределенноеЗначение("Перечисление.ВидыТорговогоОборудования.ККТ"), Объект.КассаККМ);
		
	КоличествоККТ = МассивККТ.Количество();
	Если КоличествоККТ = 0 Тогда
		ТекстСообщения = НСтр("ru='Отсутствуют доступные фискальные устройства'");
		ОбщегоНазначения.СообщитьИнформациюПользователю(ТекстСообщения);
	ИначеЕсли КоличествоККТ = 1 Тогда
		ККТ = МассивККТ[0];
	Иначе
		ПредставлениеУстройства = "";
		ВидУстройства = "";
		СписокККТ = Новый СписокЗначений;

		Для Каждого Устройство Из МассивККТ Цикл
			ПолучитьСерверТО().ПолучитьПредставлениеУстройства(Устройство, ВидУстройства, ПредставлениеУстройства);
			СписокККТ.Добавить(Устройство, ПредставлениеУстройства);
		КонецЦикла;

		ККТ = СписокККТ.ВыбратьЭлемент("Необходимо выбрать фискальное устройство");
		Если ККТ <> Неопределено Тогда
			ККТ = ККТ.Значение;
		КонецЕсли;
	КонецЕсли;
	
	Если ККТ = NULL ИЛИ ККТ = Неопределено Тогда
		Возврат;
	КонецЕсли;

	НапечататьЧекКоррекцииКлиент(ККТ);
	
КонецПроцедуры

//#КонецОбласти

//#Область СлужебныеПроцедуры

//#Область СлужебныеПроцедурыКлеинт

&НаСервере
Функция ВернутьИтогиОплатыПоВиду(ТипОплаты) Экспорт
	
	ПараметрыОтбора = Новый Структура;
	ПараметрыОтбора.Вставить("ТипОплаты", ТипОплаты);
	НайденныеСтроки = Объект.Оплата.Выгрузить(ПараметрыОтбора,"Сумма");
	Возврат НайденныеСтроки.Итог("Сумма");
	
КонецФункции

&НаСервере
Функция ПолучитьПараметрыЧека()
	
	РеквизитыКассир = ПолучитьРеквизитыКассира();
	
	ПараметрыЧека = МенеджерОборудованияКлиентСервер.ПараметрыОперацииЧекаКоррекции();
		
	ПараметрыЧека.ТипРасчета = Объект.ТипРасчета;
	ПараметрыЧека.Кассир     = РеквизитыКассир.Наименование; // ФИО лица, осуществившего расчет с покупателем (клиентом), оформившего кассовый чек.
	ПараметрыЧека.КассирИНН  = РеквизитыКассир.ИНН; // Идентификационный номер налогоплательщика кассира, при наличии.
	ПараметрыЧека.Сумма      = Объект.СуммаДокумента;
	
	ПараметрыЧека.СистемаНалогообложения  = Объект.СистемаНалогообложения;  // Системы налогообложения
	ПараметрыЧека.НаименованиеОснования   = Объект.ОснованиеДляКоррекции;   // Наименование документа основания для коррекции
	ПараметрыЧека.ДатаДокументаОснования  = Объект.ДатаДокументаОснования + 1;  // Дата документа основания для коррекции
	ПараметрыЧека.НомерДокументаОснования = Объект.НомерДокументаОснования; // Номер документа основания для коррекции
		
	ПараметрыЧека.СуммаБезНДС = Объект.СуммаБезНДС;
	ПараметрыЧека.СуммаНДС0   = Объект.СуммаНДС0;
	ПараметрыЧека.СуммаНДС10  = Объект.СуммаНДС10;
	ПараметрыЧека.СуммаНДС18  = Объект.СуммаНДС18;
	ПараметрыЧека.СуммаНДС20  = Объект.СуммаНДС20;
	ПараметрыЧека.СуммаНДС110 = Объект.СуммаНДС110;
	ПараметрыЧека.СуммаНДС118 = Объект.СуммаНДС118;
	ПараметрыЧека.СуммаНДС120 = Объект.СуммаНДС120;
	
	ПараметрыЧека.НаличнаяОплата           = ВернутьИтогиОплатыПоВиду(Перечисления.ТипыОплатыККТ.Наличные);
	ПараметрыЧека.ЭлектроннаяОплаты        = ВернутьИтогиОплатыПоВиду(Перечисления.ТипыОплатыККТ.Электронно);
	ПараметрыЧека.Предоплатой              = ВернутьИтогиОплатыПоВиду(Перечисления.ТипыОплатыККТ.Предоплата);
	ПараметрыЧека.Постоплатой              = ВернутьИтогиОплатыПоВиду(Перечисления.ТипыОплатыККТ.Постоплата);
	ПараметрыЧека.ВстречнымПредоставлением = ВернутьИтогиОплатыПоВиду(Перечисления.ТипыОплатыККТ.ВстречноеПредоставление);
	
	Возврат ПараметрыЧека;
	
КонецФункции

&НаКлиенте
Процедура НапечататьЧекКоррекцииКлиент(ФУ)
	
	Если ФУ = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ОбъектДрайвера = Неопределено;
	ОбработкаОбслуживания = Неопределено;
	ПолучитьСерверТО().ПолучитьОбъектДрайвера(ФУ, ОбработкаОбслуживания, ОбъектДрайвера);
	
	Если ОбработкаОбслуживания = Неопределено Тогда
		ОбщегоНазначения.СообщитьОбОшибке("Ошибка получения обработки обслуживания");
	Иначе
		
		ПараметрыЧека = ПолучитьПараметрыЧека();
		РезультатВыполнения = ОбработкаОбслуживания.НапечататьЧекКоррекции(ОбъектДрайвера, ПараметрыЧека);
		
		Если РезультатВыполнения <> ПредопределенноеЗначение("Перечисление.ТООшибкиОбщие.ПустаяСсылка") Тогда
			ОбщегоНазначения.СообщитьОбОшибке(ОбъектДрайвера.ОписаниеОшибки);
		Иначе
			Объект.НомерЧекаККМ = ОбъектДрайвера.ВыходныеПараметры[1];
			Объект.ПробитЧек    = Истина;
			Модифицированность  = Истина;
			ПодключаемоеОборудование = ФУ;
			РезультатЗаписи = Записать(Новый Структура("РежимЗаписи", РежимЗаписиДокумента.Проведение));
		КонецЕсли;
		
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Функция ПоддерживаетсяВидТО(Вид) Экспорт

	Результат = Ложь;

	Если Вид = ПредопределенноеЗначение("Перечисление.ВидыТорговогоОборудования.ККТ") Тогда
		Результат = Истина;
	КонецЕсли;

	Возврат Результат;

КонецФункции // ПоддерживаетсяВидТО()

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	ПолучитьСерверТО().ПодключитьКлиента(ЭтаФорма);
	ЭтаФорма.ТолькоПросмотр = Истина;
	ЭтаФорма.Элементы.НапечататьЧек.Доступность = Ложь;
КонецПроцедуры

&НаКлиенте
Процедура ПриЗакрытии()
	
	ПолучитьСерверТО().ОтключитьКлиента(ЭтаФорма);
	
КонецПроцедуры

//#КонецОбласти

//#Область СлужебныеПроцедурыСервер

&НаСервере
Процедура УстановитьДоступностьЭлементовИФормы()
	
	ТолькоПросмотр = ТолькоПросмотр ИЛИ Объект.ПробитЧек;
	
	ТолькоПросмотр = ТолькоПросмотр ИЛИ ЗначениеЗаполнено(Объект.НомерЧекаККМ);
	
	Элементы.НапечататьЧек.Доступность = НЕ ТолькоПросмотр;
	
КонецПроцедуры

&НаСервере
Функция ПолучитьРеквизитыКассира()
	
	РеквизитыКассир = Новый Структура("Наименование, ИНН", Объект.Ответственный.Наименование, "");
	
	Возврат РеквизитыКассир;
	
КонецФункции

&НаКлиенте
Процедура ПересчитатьДокументНаКлиенте()
	
	Объект.СуммаДокумента = Объект.Оплата.Итог("Сумма");
	
КонецПроцедуры

//#КонецОбласти

//#КонецОбласти