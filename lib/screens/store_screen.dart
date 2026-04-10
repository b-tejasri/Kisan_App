// KisanAI – Certified Fertilizer Store Screen
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class StoreProduct {
  final String name, emoji, type, company, description, dose, suitableFor, badge;
  final double pricePerKg, localShopPrice;
  final bool certified;
  const StoreProduct({
    required this.name, required this.emoji, required this.type,
    required this.company, required this.description, required this.dose,
    required this.suitableFor, required this.pricePerKg, required this.localShopPrice,
    this.certified = true, this.badge = '',
  });
  double get savings => localShopPrice - pricePerKg;
  double get savingsPct => (savings / localShopPrice) * 100;
}

const _products = <StoreProduct>[
  StoreProduct(name:'Neem Cake (Organic)',emoji:'🌿',type:'Organic',company:'IFFCO Organic',
    description:'Cold-pressed neem seed cake. Controls soil pests and adds slow-release nitrogen.',
    dose:'200-250 kg/acre at land preparation',suitableFor:'Rice, Tomato, Chilli, Groundnut, Cotton, all crops',
    pricePerKg:8,localShopPrice:14,badge:'Best Seller'),
  StoreProduct(name:'Vermicompost',emoji:'🪱',type:'Organic',company:'KRIBHCO Green',
    description:'Earthworm-processed compost rich in micronutrients and beneficial microbes.',
    dose:'300-500 kg/acre before sowing',suitableFor:'All vegetables, rice, pulses, cotton',
    pricePerKg:6,localShopPrice:10,badge:'Govt Approved'),
  StoreProduct(name:'Rhizobium Culture',emoji:'🦠',type:'Organic',company:'TNAU Bio-Products',
    description:'Live nitrogen-fixing bacteria for pulse crops. Saves 30-40 kg urea per acre.',
    dose:'600g per 30 kg seed (seed treatment)',suitableFor:'Groundnut, Red Gram, Green Gram, Soybean',
    pricePerKg:45,localShopPrice:70,badge:'Best Seller'),
  StoreProduct(name:'Trichoderma viride',emoji:'🍄',type:'Organic',company:'Biostadt India',
    description:'Beneficial fungus that attacks plant diseases in soil. Reduces chemical fungicide use.',
    dose:'2.5 kg/acre soil drench or foliar spray',suitableFor:'Rice, Tomato, Chilli, Cotton, Groundnut',
    pricePerKg:110,localShopPrice:160,badge:'New'),
  StoreProduct(name:'Pseudomonas fluorescens',emoji:'🌱',type:'Organic',company:'IARI Biopesticide',
    description:'Natural disease-fighting bacteria. Effective against leaf blight and wilt.',
    dose:'2.5 kg/acre soil drench at planting',suitableFor:'Chilli, Tomato, Rice, Groundnut',
    pricePerKg:125,localShopPrice:180,badge:'Govt Approved'),
  StoreProduct(name:'Seaweed Liquid Extract',emoji:'🌊',type:'Organic',company:'Seasol India',
    description:'Concentrated seaweed with 60+ growth hormones and micronutrients.',
    dose:'2-3 ml/L foliar spray every 15 days',suitableFor:'All vegetable and fruit crops',
    pricePerKg:175,localShopPrice:260,badge:'Best Seller'),
  StoreProduct(name:'Panchagavya Bio-spray',emoji:'🐄',type:'Organic',company:'Traditional Formula',
    description:'Traditional 5-cow product. Boosts natural immunity, safe for all crops.',
    dose:'30 ml/L foliar spray weekly',suitableFor:'All crops especially vegetables',
    pricePerKg:38,localShopPrice:55,badge:''),
  StoreProduct(name:'FYM (Farm Yard Manure)',emoji:'🏺',type:'Organic',company:'Local Certified',
    description:'Lab-tested processed cattle manure. Improves soil structure and provides all nutrients.',
    dose:'2-4 tonnes/acre before sowing',suitableFor:'All crops',
    pricePerKg:2.5,localShopPrice:4,badge:''),
  StoreProduct(name:'Urea 46% Nitrogen',emoji:'💊',type:'Chemical',company:'IFFCO / NFL',
    description:'Most common nitrogen fertilizer. Essential for vegetative growth and grain formation.',
    dose:'25-50 kg/acre split in 2-3 applications',suitableFor:'Rice, Maize, Cotton, Vegetables — all crops',
    pricePerKg:5.8,localShopPrice:7.5,badge:'Best Seller'),
  StoreProduct(name:'DAP 18-46-00',emoji:'🔵',type:'Chemical',company:'IFFCO / Zuari',
    description:'High phosphorus fertilizer. Critical for root development, flowering and pod set.',
    dose:'25-50 kg/acre as basal at sowing',suitableFor:'All crops especially pulses, oilseeds',
    pricePerKg:27,localShopPrice:34,badge:'Govt Approved'),
  StoreProduct(name:'NPK 17-17-17 (Water Soluble)',emoji:'🎯',type:'Chemical',company:'Yara India',
    description:'Balanced all-nutrient fertilizer. Equal nitrogen, phosphorus and potassium.',
    dose:'25 kg/acre basal or 3g/L foliar spray',suitableFor:'All crops — excellent for fertigation',
    pricePerKg:48,localShopPrice:65,badge:'Best Seller'),
  StoreProduct(name:'MOP (Muriate of Potash 60%)',emoji:'🟤',type:'Chemical',company:'Deepak Fertilisers',
    description:'Best potassium source. Improves disease resistance, fruit quality and shelf life.',
    dose:'15-25 kg/acre basal or top dressing',suitableFor:'Tomato, Chilli, Potato, Cotton, Rice',
    pricePerKg:28,localShopPrice:38,badge:''),
  StoreProduct(name:'Gypsum (Calcium Sulphate)',emoji:'⬜',type:'Chemical',company:'Coromandel',
    description:'Essential calcium and sulphur. Must-use for groundnut pod filling.',
    dose:'200 kg/acre at pegging stage',suitableFor:'Groundnut, Chilli, Tomato, Cotton',
    pricePerKg:6,localShopPrice:9,badge:'Govt Approved'),
  StoreProduct(name:'Zinc Sulphate 21%',emoji:'🔩',type:'Chemical',company:'Gujarat Narmada',
    description:'Corrects zinc deficiency — causes khaira disease in rice and stunted growth.',
    dose:'10 kg/acre basal or 2g/L foliar spray',suitableFor:'Rice, Maize, Wheat, Vegetables',
    pricePerKg:45,localShopPrice:62,badge:''),
  StoreProduct(name:'Calcium Nitrate',emoji:'🦴',type:'Chemical',company:'Yara India',
    description:'Soluble calcium + nitrogen. Strengthens cell walls, prevents blossom end rot.',
    dose:'2g/L foliar spray every 10-15 days',suitableFor:'Tomato, Chilli, Capsicum, Potato',
    pricePerKg:52,localShopPrice:75,badge:''),
  StoreProduct(name:'MKP 00-52-34',emoji:'🌸',type:'Chemical',company:'SQM India',
    description:'High P+K for flowering and fruiting. Boosts fruit weight and sugar content.',
    dose:'2g/L foliar spray at flowering',suitableFor:'Tomato, Chilli, Mango, Grapes, Pomegranate',
    pricePerKg:145,localShopPrice:200,badge:'New'),
  StoreProduct(name:'Boron (Solubor 20%)',emoji:'🧊',type:'Chemical',company:'U.S. Borax India',
    description:'Improves pollen viability, increases fruit set by 20-30%. Prevents hollow heart.',
    dose:'1g/L foliar spray at flowering',suitableFor:'Cotton, Sunflower, Groundnut, Tomato',
    pricePerKg:130,localShopPrice:180,badge:''),
];

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});
  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;
  String _search = '';
  String _crop = 'All Crops';

  static const _crops = ['All Crops','Rice','Tomato','Maize','Chilli','Groundnut','Cotton','Red Gram','Green Gram'];

  @override
  void initState() { super.initState(); _tabs = TabController(length:3,vsync:this); }
  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  List<StoreProduct> _filter(String type) => _products.where((p) {
    final t = type == 'All' || p.type == type;
    final s = _search.isEmpty || p.name.toLowerCase().contains(_search.toLowerCase()) || p.suitableFor.toLowerCase().contains(_search.toLowerCase());
    final c = _crop == 'All Crops' || p.suitableFor.toLowerCase().contains(_crop.toLowerCase());
    return t && s && c;
  }).toList();

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: KisanColors.cream,
    body: NestedScrollView(
      headerSliverBuilder: (_,__) => [
        SliverAppBar(
          backgroundColor: KisanColors.leafDeep,
          pinned: true,
          expandedHeight: 0,
          title: Text('🛒  Certified Fertilizer Store', style: GoogleFonts.lora(color:Colors.white,fontSize:17,fontWeight:FontWeight.w700)),
          bottom: TabBar(
            controller: _tabs,
            indicatorColor: KisanColors.sun,
            labelColor: KisanColors.sun,
            unselectedLabelColor: Colors.white60,
            labelStyle: GoogleFonts.nunito(fontSize:12,fontWeight:FontWeight.w800),
            tabs: const [Tab(text:'ALL'), Tab(text:'🌿 ORGANIC'), Tab(text:'🧪 CHEMICAL')],
          ),
        ),
      ],
      body: Column(children:[
        _banner(),
        _searchBar(),
        _cropFilter(),
        Expanded(child: TabBarView(controller:_tabs, children:[
          _list(_filter('All')),
          _list(_filter('Organic')),
          _list(_filter('Chemical')),
        ])),
      ]),
    ),
  );

  Widget _banner() => Container(
    margin: const EdgeInsets.fromLTRB(14,14,14,0),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors:[Color(0xFF0D4F2C),Color(0xFF1B6B3C)]),
      borderRadius: BorderRadius.circular(16)),
    child: Row(children:[
      const Text('🛡️',style:TextStyle(fontSize:26)),
      const SizedBox(width:12),
      Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text('100% Certified — Anti-Fraud Protected',style:GoogleFonts.nunito(fontSize:12,fontWeight:FontWeight.w800,color:Colors.white)),
        Text('QR code inside every pack. Tap to verify.',style:GoogleFonts.nunito(fontSize:10,color:Colors.white60,fontWeight:FontWeight.w600)),
      ])),
      GestureDetector(
        onTap:() => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('📷 Opening QR scanner...'),backgroundColor:KisanColors.leaf)),
        child: Container(padding:const EdgeInsets.symmetric(horizontal:10,vertical:6),
          decoration:BoxDecoration(color:KisanColors.sun,borderRadius:BorderRadius.circular(10)),
          child:Text('Verify QR',style:GoogleFonts.nunito(fontSize:11,fontWeight:FontWeight.w800,color:Colors.white))),
      ),
    ]),
  );

  Widget _searchBar() => Padding(
    padding: const EdgeInsets.fromLTRB(14,10,14,0),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal:14,vertical:10),
      decoration: BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(14),border:Border.all(color:KisanColors.border)),
      child: Row(children:[
        const Text('🔍',style:TextStyle(fontSize:18)),
        const SizedBox(width:8),
        Expanded(child:TextField(
          onChanged:(v)=>setState(()=>_search=v),
          style: GoogleFonts.nunito(fontSize:13,fontWeight:FontWeight.w600,color:KisanColors.textDark),
          decoration: InputDecoration(
            hintText:'Search fertilizer or crop...',
            hintStyle:GoogleFonts.nunito(fontSize:13,color:KisanColors.textLight,fontWeight:FontWeight.w600),
            border:InputBorder.none,isDense:true,contentPadding:EdgeInsets.zero),
        )),
      ]),
    ),
  );

  Widget _cropFilter() => SizedBox(
    height:42,
    child: ListView.builder(
      scrollDirection:Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(14,8,14,0),
      itemCount:_crops.length,
      itemBuilder:(_,i) {
        final sel = _crops[i]==_crop;
        return GestureDetector(
          onTap:()=>setState(()=>_crop=_crops[i]),
          child:Container(
            margin: const EdgeInsets.only(right:8),
            padding: const EdgeInsets.symmetric(horizontal:12,vertical:5),
            decoration:BoxDecoration(
              color:sel?KisanColors.leaf:Colors.white,
              borderRadius:BorderRadius.circular(20),
              border:Border.all(color:sel?KisanColors.leaf:KisanColors.border,width:1.5)),
            child:Text(_crops[i],style:GoogleFonts.nunito(fontSize:11,fontWeight:FontWeight.w700,color:sel?Colors.white:KisanColors.textMid)),
          ),
        );
      },
    ),
  );

  Widget _list(List<StoreProduct> products) {
    if(products.isEmpty) return Center(child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
      const Text('🌾',style:TextStyle(fontSize:48)),
      const SizedBox(height:12),
      Text('No products found',style:GoogleFonts.nunito(fontSize:15,fontWeight:FontWeight.w700,color:KisanColors.textMid)),
    ]));
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14,12,14,90),
      itemCount:products.length,
      itemBuilder:(_,i)=>_card(products[i]),
    );
  }

  Widget _card(StoreProduct p) {
    final isOrganic = p.type=='Organic';
    final accent = isOrganic ? KisanColors.leaf : const Color(0xFF2040B0);
    final bg = isOrganic ? KisanColors.leafPale : const Color(0xFFEEF2FF);
    return Container(
      margin: const EdgeInsets.only(bottom:12),
      decoration: BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(18),
        boxShadow:[BoxShadow(color:Colors.black.withOpacity(0.05),blurRadius:8,offset:const Offset(0,2))]),
      child: Column(children:[
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color:bg,borderRadius:const BorderRadius.vertical(top:Radius.circular(18))),
          child: Row(children:[
            Container(width:52,height:52,decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(14)),
              child:Center(child:Text(p.emoji,style:const TextStyle(fontSize:28)))),
            const SizedBox(width:12),
            Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
              Row(children:[
                Expanded(child:Text(p.name,style:GoogleFonts.nunito(fontSize:13,fontWeight:FontWeight.w800,color:KisanColors.textDark))),
                if(p.badge.isNotEmpty) Container(
                  padding: const EdgeInsets.symmetric(horizontal:7,vertical:3),
                  decoration:BoxDecoration(color:accent,borderRadius:BorderRadius.circular(20)),
                  child:Text(p.badge,style:GoogleFonts.nunito(fontSize:9,fontWeight:FontWeight.w800,color:Colors.white))),
              ]),
              Text(p.company,style:GoogleFonts.nunito(fontSize:11,color:KisanColors.textMid,fontWeight:FontWeight.w600)),
              const SizedBox(height:4),
              Row(children:[
                Container(padding:const EdgeInsets.symmetric(horizontal:6,vertical:2),
                  decoration:BoxDecoration(color:accent.withOpacity(0.12),borderRadius:BorderRadius.circular(6)),
                  child:Text(p.type,style:GoogleFonts.nunito(fontSize:10,fontWeight:FontWeight.w800,color:accent))),
                const SizedBox(width:6),
                Text('✅ Certified',style:GoogleFonts.nunito(fontSize:10,fontWeight:FontWeight.w700,color:KisanColors.leaf)),
              ]),
            ])),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Text(p.description,style:GoogleFonts.nunito(fontSize:12,color:KisanColors.textDark,fontWeight:FontWeight.w600,height:1.4)),
            const SizedBox(height:8),
            _info('💊 Dose',p.dose),
            _info('🌾 For',p.suitableFor),
            const SizedBox(height:12),
            Row(children:[
              Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                Text('KisanAI Price',style:GoogleFonts.nunito(fontSize:10,color:KisanColors.textMid,fontWeight:FontWeight.w700)),
                Text('₹${p.pricePerKg%1==0?p.pricePerKg.toInt():p.pricePerKg}/kg',
                  style:GoogleFonts.lora(fontSize:20,fontWeight:FontWeight.w700,color:KisanColors.leaf)),
              ])),
              Column(crossAxisAlignment:CrossAxisAlignment.end,children:[
                Text('Local Shop',style:GoogleFonts.nunito(fontSize:10,color:KisanColors.textLight)),
                Text('₹${p.localShopPrice}/kg',style:GoogleFonts.nunito(fontSize:13,color:KisanColors.textLight,decoration:TextDecoration.lineThrough,fontWeight:FontWeight.w700)),
                Text('Save ${p.savingsPct.toStringAsFixed(0)}%!',style:GoogleFonts.nunito(fontSize:11,fontWeight:FontWeight.w800,color:KisanColors.alertRed)),
              ]),
            ]),
            const SizedBox(height:12),
            Row(children:[
              Expanded(child:GestureDetector(
                onTap:()=>ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content:Text('✅ ${p.name} added to cart!',style:GoogleFonts.nunito(fontWeight:FontWeight.w700)),
                  backgroundColor:KisanColors.leaf,behavior:SnackBarBehavior.floating,
                  shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(12)))),
                child:Container(
                  padding: const EdgeInsets.symmetric(vertical:11),
                  decoration:BoxDecoration(gradient:LinearGradient(colors:[accent,accent.withOpacity(0.75)]),borderRadius:BorderRadius.circular(12)),
                  child:Center(child:Text('🛒  Add to Cart',style:GoogleFonts.nunito(fontSize:13,fontWeight:FontWeight.w800,color:Colors.white)))),
              )),
              const SizedBox(width:10),
              GestureDetector(
                onTap:()=>showModalBottomSheet(context:context,backgroundColor:Colors.transparent,isScrollControlled:true,
                  builder:(_)=>_DetailSheet(product:p)),
                child:Container(
                  padding: const EdgeInsets.symmetric(vertical:11,horizontal:16),
                  decoration:BoxDecoration(border:Border.all(color:accent,width:1.5),borderRadius:BorderRadius.circular(12)),
                  child:Text('Details',style:GoogleFonts.nunito(fontSize:13,fontWeight:FontWeight.w800,color:accent))),
              ),
            ]),
          ]),
        ),
      ]),
    );
  }

  Widget _info(String k,String v) => Padding(
    padding: const EdgeInsets.only(bottom:4),
    child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
      SizedBox(width:60,child:Text(k,style:GoogleFonts.nunito(fontSize:10,fontWeight:FontWeight.w800,color:KisanColors.textMid))),
      Expanded(child:Text(v,style:GoogleFonts.nunito(fontSize:11,color:KisanColors.textDark,fontWeight:FontWeight.w600,height:1.3))),
    ]),
  );
}

class _DetailSheet extends StatelessWidget {
  final StoreProduct product;
  const _DetailSheet({required this.product});
  @override
  Widget build(BuildContext context) {
    final isO = product.type=='Organic';
    final accent = isO ? KisanColors.leaf : const Color(0xFF2040B0);
    return DraggableScrollableSheet(
      initialChildSize:0.65,maxChildSize:0.95,minChildSize:0.4,
      builder:(_,ctrl)=>Container(
        decoration: const BoxDecoration(color:Colors.white,borderRadius:BorderRadius.vertical(top:Radius.circular(24))),
        child:ListView(controller:ctrl,padding: const EdgeInsets.all(20),children:[
          Center(child:Container(width:40,height:4,decoration:BoxDecoration(color:Colors.grey[300],borderRadius:BorderRadius.circular(2)))),
          const SizedBox(height:16),
          Row(children:[
            Text(product.emoji,style: const TextStyle(fontSize:48)),
            const SizedBox(width:16),
            Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
              Text(product.name,style:GoogleFonts.lora(fontSize:17,fontWeight:FontWeight.w700,color:KisanColors.textDark)),
              Text(product.company,style:GoogleFonts.nunito(fontSize:12,color:KisanColors.textMid,fontWeight:FontWeight.w600)),
              const SizedBox(height:6),
              Container(padding: const EdgeInsets.symmetric(horizontal:10,vertical:4),
                decoration:BoxDecoration(color:accent.withOpacity(0.1),borderRadius:BorderRadius.circular(8)),
                child:Text('${product.type} • ✅ Govt Certified',style:GoogleFonts.nunito(fontSize:11,fontWeight:FontWeight.w800,color:accent))),
            ])),
          ]),
          const SizedBox(height:14),
          Text(product.description,style:GoogleFonts.nunito(fontSize:13,color:KisanColors.textDark,fontWeight:FontWeight.w600,height:1.5)),
          const SizedBox(height:14),
          _r('💊 Dose',product.dose,accent),
          _r('🌾 For',product.suitableFor,accent),
          const SizedBox(height:16),
          Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
            Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
              Text('KisanAI Price',style:GoogleFonts.nunito(fontSize:11,color:KisanColors.textMid,fontWeight:FontWeight.w700)),
              Text('₹${product.pricePerKg}/kg',style:GoogleFonts.lora(fontSize:26,fontWeight:FontWeight.w700,color:KisanColors.leaf)),
            ]),
            Column(crossAxisAlignment:CrossAxisAlignment.end,children:[
              Text('vs Local Shop',style:GoogleFonts.nunito(fontSize:10,color:KisanColors.textLight)),
              Text('₹${product.localShopPrice}/kg',style:GoogleFonts.nunito(fontSize:15,color:KisanColors.textLight,decoration:TextDecoration.lineThrough)),
              Text('Save ${product.savingsPct.toStringAsFixed(0)}%',style:GoogleFonts.nunito(fontSize:13,fontWeight:FontWeight.w800,color:KisanColors.alertRed)),
            ]),
          ]),
          const SizedBox(height:18),
          GestureDetector(
            onTap:()=>Navigator.pop(context),
            child:Container(
              padding: const EdgeInsets.symmetric(vertical:14),
              decoration:BoxDecoration(gradient:LinearGradient(colors:[accent,accent.withOpacity(0.75)]),borderRadius:BorderRadius.circular(16)),
              child:Center(child:Text('🛒  Order Now — Certified & Delivered',style:GoogleFonts.nunito(fontSize:14,fontWeight:FontWeight.w800,color:Colors.white)))),
          ),
        ]),
      ),
    );
  }
  Widget _r(String k,String v,Color a)=>Container(
    margin: const EdgeInsets.only(bottom:10),
    padding: const EdgeInsets.all(12),
    decoration:BoxDecoration(color:a.withOpacity(0.06),borderRadius:BorderRadius.circular(12)),
    child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text(k,style:GoogleFonts.nunito(fontSize:10,fontWeight:FontWeight.w800,color:a,letterSpacing:0.5)),
      const SizedBox(height:3),
      Text(v,style:GoogleFonts.nunito(fontSize:13,color:KisanColors.textDark,fontWeight:FontWeight.w600,height:1.4)),
    ]),
  );
}
